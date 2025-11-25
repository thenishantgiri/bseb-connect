import { Controller, Post, Body, UseInterceptors, UploadedFiles } from '@nestjs/common';
import { FileFieldsInterceptor } from '@nestjs/platform-express';
import { Throttle } from '@nestjs/throttler';
import { AuthService } from './auth.service';
import { MinioService } from '../minio/minio.service';
import { FileValidationService } from '../common/file-validation.service';
import { SendOtpDto, VerifyOtpDto, LoginPasswordDto, ForgotPasswordDto, ResetPasswordDto, ChangePasswordDto } from './dto/auth.dto';
import { RegisterDto } from './dto/register.dto';
import { VerifyBsebCredentialsDto, LinkBsebAccountDto } from './dto/verify-bseb.dto';

@Controller('auth')
export class AuthController {
  constructor(
    private authService: AuthService,
    private minioService: MinioService,
    private fileValidationService: FileValidationService,
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
}
