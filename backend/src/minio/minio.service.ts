import { Injectable, OnModuleInit } from '@nestjs/common';
import * as Minio from 'minio';

@Injectable()
export class MinioService implements OnModuleInit {
  private minioClient: Minio.Client;
  private readonly bucketName = process.env.S3_BUCKET_NAME || 'bseb-connect-uploads';
  private readonly region = process.env.S3_REGION || 'ap-south-1';

  async onModuleInit() {
    const endpoint = process.env.MINIO_ENDPOINT || 'localhost';
    const isS3 = endpoint.includes('amazonaws.com');

    // Initialize MinIO/S3 client
    this.minioClient = new Minio.Client({
      endPoint: endpoint,
      port: isS3 ? 443 : parseInt(process.env.MINIO_PORT || '9000'),
      useSSL: isS3 || process.env.MINIO_USE_SSL === 'true',
      accessKey: process.env.MINIO_ACCESS_KEY || 'minioadmin',
      secretKey: process.env.MINIO_SECRET_KEY || 'minioadmin',
      region: this.region,
    });

    // Create bucket if it doesn't exist (skip for S3 - bucket should be pre-created)
    if (!isS3) {
      try {
        const exists = await this.minioClient.bucketExists(this.bucketName);
        if (!exists) {
          await this.minioClient.makeBucket(this.bucketName, this.region);
          console.log(`✅ Created MinIO bucket: ${this.bucketName}`);
        }
      } catch (error) {
        console.error('MinIO bucket creation error:', error);
      }
    } else {
      console.log(`✅ Using AWS S3 bucket: ${this.bucketName}`);
    }
  }

  async uploadFile(
    file: Express.Multer.File,
    folder: string,
  ): Promise<string> {
    const fileName = `${folder}/${Date.now()}-${file.originalname}`;
    
    await this.minioClient.putObject(
      this.bucketName,
      fileName,
      file.buffer,
      file.size,
      {
        'Content-Type': file.mimetype,
      },
    );

    return fileName;
  }

  async getFileUrl(fileName: string): Promise<string> {
    // Generate presigned URL (valid for 7 days)
    return await this.minioClient.presignedGetObject(
      this.bucketName,
      fileName,
      7 * 24 * 60 * 60,
    );
  }

  async deleteFile(fileName: string): Promise<void> {
    await this.minioClient.removeObject(this.bucketName, fileName);
  }
}
