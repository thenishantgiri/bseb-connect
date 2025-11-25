// Updated Auth Controller methods for MSG91 OTP integration
// Add these methods to your existing auth.controller.ts

import { Msg91Service } from '../common/msg91.service';

// Add to constructor
constructor(
  private authService: AuthService,
  private msg91Service: Msg91Service, // Add this
) {}

/**
 * Send OTP for login/registration
 */
@Post('send-otp')
@ApiOperation({ summary: 'Send OTP to mobile/email' })
async sendOTP(@Body() dto: SendOTPDto) {
  const { identifier, type = 'login' } = dto;

  // Check if identifier is mobile or email
  const isMobile = /^\+?[0-9]{10,13}$/.test(identifier);

  if (isMobile) {
    // Validate mobile number
    if (!this.msg91Service.validateMobile(identifier)) {
      throw new BadRequestException('Invalid mobile number');
    }

    // Send OTP via MSG91
    const success = await this.msg91Service.sendOTP(identifier);

    if (!success) {
      throw new InternalServerErrorException('Failed to send OTP');
    }

    return {
      success: true,
      message: 'OTP sent to mobile number',
      identifier: identifier.replace(/.(?=.{4})/g, '*'), // Mask mobile
    };
  } else {
    // Handle email OTP (existing logic)
    return this.authService.sendEmailOTP(identifier, type);
  }
}

/**
 * Verify OTP for login
 */
@Post('verify-otp')
@ApiOperation({ summary: 'Verify OTP and login' })
async verifyOTP(@Body() dto: VerifyOTPDto) {
  const { identifier, otp } = dto;

  // Check if identifier is mobile or email
  const isMobile = /^\+?[0-9]{10,13}$/.test(identifier);

  if (isMobile) {
    // Verify OTP via MSG91
    const isValid = await this.msg91Service.verifyOTP(identifier, otp);

    if (!isValid) {
      throw new UnauthorizedException('Invalid or expired OTP');
    }

    // Find or create user
    let user = await this.authService.findUserByPhone(identifier);

    if (!user) {
      // Create new user with phone
      user = await this.authService.createUserWithPhone({
        phone: identifier,
        isPhoneVerified: true,
      });
    }

    // Generate tokens
    return this.authService.generateTokens(user);
  } else {
    // Handle email OTP verification (existing logic)
    return this.authService.verifyEmailOTP(identifier, otp);
  }
}

/**
 * Resend OTP
 */
@Post('resend-otp')
@ApiOperation({ summary: 'Resend OTP' })
@ApiResponse({ status: 200, description: 'OTP resent successfully' })
@ApiResponse({ status: 429, description: 'Too many requests' })
async resendOTP(@Body() dto: ResendOTPDto) {
  const { identifier } = dto;

  const isMobile = /^\+?[0-9]{10,13}$/.test(identifier);

  if (isMobile) {
    const success = await this.msg91Service.resendOTP(identifier);

    if (!success) {
      throw new HttpException(
        'Please wait before requesting another OTP',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    return {
      success: true,
      message: 'OTP resent successfully',
    };
  } else {
    // Handle email OTP resend
    return this.authService.resendEmailOTP(identifier);
  }
}