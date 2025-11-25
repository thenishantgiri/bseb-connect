import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { RedisService } from '../redis/redis.service';

@Injectable()
export class Msg91Service {
  private readonly logger = new Logger(Msg91Service.name);
  private readonly authKey: string;
  private readonly templateId: string;
  private readonly senderId: string;
  private readonly baseUrl = 'https://control.msg91.com/api/v5';

  constructor(
    private configService: ConfigService,
    private httpService: HttpService,
    private redisService: RedisService,
  ) {
    this.authKey = this.configService.get('MSG91_AUTH_KEY');
    this.templateId = this.configService.get('MSG91_TEMPLATE_ID');
    this.senderId = this.configService.get('MSG91_SENDER_ID', 'BSEBAP');
  }

  /**
   * Send OTP to mobile number
   */
  async sendOTP(mobile: string, otp?: string): Promise<boolean> {
    try {
      // Generate OTP if not provided
      if (!otp) {
        otp = this.generateOTP();
      }

      // Store OTP in Redis with 10 minute expiry
      await this.redisService.set(
        `otp:${mobile}`,
        otp,
        600, // 10 minutes
      );

      // MSG91 Send OTP API
      const url = `${this.baseUrl}/otp`;

      const payload = {
        template_id: this.templateId,
        mobile: mobile.startsWith('91') ? mobile : `91${mobile}`,
        authkey: this.authKey,
        otp: otp,
        otp_length: 6,
        otp_expiry: 10, // minutes
        sender: this.senderId,
      };

      const response = await firstValueFrom(
        this.httpService.post(url, payload, {
          headers: {
            'accept': 'application/json',
            'content-type': 'application/json',
            'authkey': this.authKey,
          },
        }),
      );

      this.logger.log(`OTP sent successfully to ${mobile}`);
      return response.data.type === 'success';
    } catch (error) {
      this.logger.error(`Failed to send OTP to ${mobile}:`, error.response?.data || error.message);

      // In development, allow OTP to work even if MSG91 fails
      if (this.configService.get('NODE_ENV') === 'development') {
        const devOtp = '123456';
        await this.redisService.set(`otp:${mobile}`, devOtp, 600);
        this.logger.warn(`Development mode: Using default OTP ${devOtp} for ${mobile}`);
        return true;
      }

      return false;
    }
  }

  /**
   * Verify OTP
   */
  async verifyOTP(mobile: string, otp: string): Promise<boolean> {
    try {
      // Get stored OTP from Redis
      const storedOtp = await this.redisService.get(`otp:${mobile}`);

      if (!storedOtp) {
        this.logger.warn(`No OTP found for ${mobile}`);
        return false;
      }

      // Verify OTP
      if (storedOtp === otp) {
        // Delete OTP after successful verification
        await this.redisService.del(`otp:${mobile}`);
        this.logger.log(`OTP verified successfully for ${mobile}`);
        return true;
      }

      // Also verify with MSG91 API for backup
      const url = `${this.baseUrl}/otp/verify`;
      const params = {
        mobile: mobile.startsWith('91') ? mobile : `91${mobile}`,
        otp: otp,
        authkey: this.authKey,
      };

      const response = await firstValueFrom(
        this.httpService.get(url, { params }),
      );

      if (response.data.type === 'success') {
        await this.redisService.del(`otp:${mobile}`);
        return true;
      }

      return false;
    } catch (error) {
      this.logger.error(`Failed to verify OTP for ${mobile}:`, error.message);

      // In development, accept default OTP
      if (this.configService.get('NODE_ENV') === 'development' && otp === '123456') {
        await this.redisService.del(`otp:${mobile}`);
        return true;
      }

      return false;
    }
  }

  /**
   * Resend OTP
   */
  async resendOTP(mobile: string): Promise<boolean> {
    try {
      // Check if OTP was recently sent (rate limiting)
      const resendKey = `otp:resend:${mobile}`;
      const canResend = await this.redisService.get(resendKey);

      if (canResend) {
        this.logger.warn(`Rate limit: Cannot resend OTP to ${mobile} yet`);
        return false;
      }

      // Set rate limit (1 minute)
      await this.redisService.set(resendKey, '1', 60);

      // MSG91 Retry OTP API
      const url = `${this.baseUrl}/otp/retry`;
      const params = {
        mobile: mobile.startsWith('91') ? mobile : `91${mobile}`,
        authkey: this.authKey,
        retrytype: 'text', // or 'voice'
      };

      const response = await firstValueFrom(
        this.httpService.get(url, { params }),
      );

      return response.data.type === 'success';
    } catch (error) {
      this.logger.error(`Failed to resend OTP to ${mobile}:`, error.message);

      // In development, just generate new OTP
      if (this.configService.get('NODE_ENV') === 'development') {
        return this.sendOTP(mobile, '123456');
      }

      return false;
    }
  }

  /**
   * Send SMS (non-OTP)
   */
  async sendSMS(mobile: string, message: string): Promise<boolean> {
    try {
      const url = `${this.baseUrl}/flow`;

      const payload = {
        sender: this.senderId,
        mobiles: mobile.startsWith('91') ? mobile : `91${mobile}`,
        message: message,
        authkey: this.authKey,
        country: '91',
        route: '4', // Transactional route
      };

      const response = await firstValueFrom(
        this.httpService.post(url, payload),
      );

      return response.data.type === 'success';
    } catch (error) {
      this.logger.error(`Failed to send SMS to ${mobile}:`, error.message);
      return false;
    }
  }

  /**
   * Generate random 6-digit OTP
   */
  private generateOTP(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  /**
   * Validate mobile number
   */
  validateMobile(mobile: string): boolean {
    // Remove country code if present
    const cleanMobile = mobile.replace(/^\+?91/, '');

    // Indian mobile number regex
    const mobileRegex = /^[6-9]\d{9}$/;
    return mobileRegex.test(cleanMobile);
  }

  /**
   * Format mobile number with country code
   */
  formatMobile(mobile: string): string {
    const cleanMobile = mobile.replace(/^\+?91/, '').replace(/\D/g, '');
    return `91${cleanMobile}`;
  }
}