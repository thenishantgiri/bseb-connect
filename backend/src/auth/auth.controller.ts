import { Controller, Post, Body, UseInterceptors, UploadedFiles, BadRequestException, InternalServerErrorException, UnauthorizedException, HttpException, HttpStatus } from '@nestjs/common';
import { FileFieldsInterceptor } from '@nestjs/platform-express';
import { Throttle } from '@nestjs/throttler';
import { ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { MinioService } from '../minio/minio.service';
import { FileValidationService } from '../common/file-validation.service';
import { Msg91Service } from '../common/msg91.service';
import { SendOtpDto, VerifyOtpDto, LoginPasswordDto, ForgotPasswordDto, ResetPasswordDto, ChangePasswordDto } from './dto/auth.dto';
import { RegisterDto } from './dto/register.dto';
import { VerifyBsebCredentialsDto, LinkBsebAccountDto } from './dto/verify-bseb.dto';

@Controller('auth')
export class AuthController {
  constructor(
    private authService: AuthService,
    private minioService: MinioService,
    private fileValidationService: FileValidationService,
    private msg91Service: Msg91Service,
  ) {}

  // SRS Requirement: Max 5 OTP requests per hour per user
  @Throttle({ long: {limit: 5, ttl: 3600000} })  // 5 requests per hour
  @Post('login/otp')
  async sendOtpLogin(@Body() dto: SendOtpDto) {
    return this.authService.sendOtpLogin(dto.identifier);
  }

  @Post('login/verify')
  async verifyLoginOtp(@Body() dto: VerifyOtpDto) {
    return this.authService.verifyLoginOtp(dto.identifier, dto.otp);
  }

  @Post('login/password')
  async loginWithPassword(@Body() dto: LoginPasswordDto) {
    return this.authService.loginWithPassword(dto.identifier, dto.password);
  }

  @Post('register')
  @UseInterceptors(
    FileFieldsInterceptor([
      { name: 'photo', maxCount: 1 },
      { name: 'signature', maxCount: 1 },
    ]),
  )
  async register(
    @Body() registerDto: RegisterDto,
    @UploadedFiles() files: { photo?: Express.Multer.File[]; signature?: Express.Multer.File[] },
  ) {
    let photoPath: string | undefined;
    let signaturePath: string | undefined;

    // Validate and upload photo (only if files are provided)
    if (files && files.photo && files.photo[0]) {
      this.fileValidationService.validatePhoto(files.photo[0]);
      photoPath = await this.minioService.uploadFile(files.photo[0], 'photos');
    }

    // Validate and upload signature (only if files are provided)
    if (files && files.signature && files.signature[0]) {
      this.fileValidationService.validateSignature(files.signature[0]);
      signaturePath = await this.minioService.uploadFile(files.signature[0], 'signatures');
    }

    return this.authService.register(registerDto, photoPath, signaturePath);
  }

  // SRS Requirement: Max 5 OTP requests per hour per user
  @Throttle({ long: {limit: 5, ttl: 3600000} })  // 5 requests per hour
  @Post('password/forgot')
  async forgotPassword(@Body() dto: ForgotPasswordDto) {
    return this.authService.forgotPassword(dto.identifier);
  }

  @Post('password/reset')
  async resetPassword(@Body() dto: ResetPasswordDto) {
    return this.authService.resetPassword(dto.identifier, dto.otp, dto.newPassword);
  }

  // SRS Requirement: BSEB Credential Verification (Path A Registration)
  @Post('verify-bseb-credentials')
  async verifyBsebCredentials(@Body() dto: VerifyBsebCredentialsDto) {
    return this.authService.verifyBsebCredentials(dto);
  }

  // SRS Requirement: Register with BSEB Credentials (auto-fetch from BSEB database)
  @Post('register/bseb-linked')
  @UseInterceptors(
    FileFieldsInterceptor([
      { name: 'photo', maxCount: 1 },
      { name: 'signature', maxCount: 1 },
    ]),
  )
  async registerWithBsebLink(
    @Body() linkDto: LinkBsebAccountDto,
    @UploadedFiles() files: { photo?: Express.Multer.File[]; signature?: Express.Multer.File[] },
  ) {
    let photoPath: string | undefined;
    let signaturePath: string | undefined;

    // Validate and upload photo (only if files are provided)
    if (files && files.photo && files.photo[0]) {
      this.fileValidationService.validatePhoto(files.photo[0]);
      photoPath = await this.minioService.uploadFile(files.photo[0], 'photos');
    }

    // Validate and upload signature (only if files are provided)
    if (files && files.signature && files.signature[0]) {
      this.fileValidationService.validateSignature(files.signature[0]);
      signaturePath = await this.minioService.uploadFile(files.signature[0], 'signatures');
    }

    return this.authService.registerWithBsebLink(linkDto, photoPath, signaturePath);
  }

  // MSG91 OTP Integration Endpoints

  /**
   * Send OTP via MSG91 for login/registration
   */
  @Post('send-otp')
  @ApiOperation({ summary: 'Send OTP to mobile/email via MSG91' })
  @Throttle({ long: {limit: 5, ttl: 3600000} })  // 5 requests per hour
  async sendOTP(@Body() dto: SendOtpDto) {
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
      return this.authService.sendOtpLogin(identifier);
    }
  }

  /**
   * Verify OTP via MSG91 for login
   */
  @Post('verify-otp')
  @ApiOperation({ summary: 'Verify OTP and login via MSG91' })
  async verifyOTP(@Body() dto: VerifyOtpDto) {
    const { identifier, otp } = dto;

    // Check if identifier is mobile or email
    const isMobile = /^\+?[0-9]{10,13}$/.test(identifier);

    if (isMobile) {
      // Verify OTP via MSG91
      const isValid = await this.msg91Service.verifyOTP(identifier, otp);

      if (!isValid) {
        throw new UnauthorizedException('Invalid or expired OTP');
      }

      // Find or create user with phone
      // Note: This requires extending the AuthService to handle phone-based auth
      // For now, we'll return a success message
      return {
        success: true,
        message: 'OTP verified successfully',
        // TODO: Generate JWT tokens here after user lookup/creation
      };
    } else {
      // Handle email OTP verification (existing logic)
      return this.authService.verifyLoginOtp(identifier, otp);
    }
  }

  /**
   * Resend OTP via MSG91
   */
  @Post('resend-otp')
  @ApiOperation({ summary: 'Resend OTP via MSG91' })
  @ApiResponse({ status: 200, description: 'OTP resent successfully' })
  @ApiResponse({ status: 429, description: 'Too many requests' })
  @Throttle({ long: {limit: 3, ttl: 3600000} })  // 3 resend requests per hour
  async resendOTP(@Body() dto: { identifier: string }) {
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
      // Handle email OTP resend - use existing login/otp endpoint
      return this.authService.sendOtpLogin(identifier);
    }
  }
}
