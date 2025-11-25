import { Injectable, OnModuleInit } from '@nestjs/common';
import * as Minio from 'minio';

@Injectable()
export class MinioService implements OnModuleInit {
  private minioClient: Minio.Client;
  private readonly bucketName = 'bseb-assets';

  async onModuleInit() {
    // Initialize MinIO client
    this.minioClient = new Minio.Client({
      endPoint: process.env.MINIO_ENDPOINT || 'localhost',
      port: parseInt(process.env.MINIO_PORT || '9000'),
      useSSL: process.env.MINIO_USE_SSL === 'true',
      accessKey: process.env.MINIO_ACCESS_KEY || 'minioadmin',
      secretKey: process.env.MINIO_SECRET_KEY || 'minioadmin',
    });

    // Create bucket if it doesn't exist
    try {
      const exists = await this.minioClient.bucketExists(this.bucketName);
      if (!exists) {
        await this.minioClient.makeBucket(this.bucketName, 'us-east-1');
        console.log(`✅ Created MinIO bucket: ${this.bucketName}`);
      }
    } catch (error) {
      console.error('MinIO bucket creation error:', error);
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
