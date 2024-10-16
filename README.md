# Localstack with S3
Use this repo to quickly spin up a localstack container with S3. Useful to locally debug projects which use S3 in production.

## Prerequisites
- Docker installed

## Usage
0. Modify `init/.env` and `aws/config` and `aws/credentials` to your needs.
1. Run `docker compose up`, done!

## Use cases
### Node.js
> Please keep in mind that your implementation might differ, follow your project's needs and conventions. Only use this for reference.

Here's what a Multer S3 middleware for Express (or compatible) apps might look like:

```ts
import multer from 'multer'
import multerS3 from 'multer-s3'

const uploadToS3 = (path: string) => multer({
    storage: multerS3({
        s3: new S3Client({
            endpoint: process.env.S3_DOMAIN,
            region: process.env.S3_REGION,
            credentials: {
                accessKeyId: process.env.S3_ACCESS_KEY_ID,
                secretAccessKey: process.env.S3_SECRET_ACCESS_KEY
            }
        }),
        bucket: process.env.S3_BUCKET_NAME,
        acl: 'public-read',
        contentType: multerS3.AUTO_CONTENT_TYPE,
        key: (req, file, cb) => {
            // dangerous; always sanitize file names in production
            const key =  file.originalname; 
            cb(null, key)
        }
    })
})

export default uploader
```

Now you can use your `uploadToS3` middleware in your routes as follows:

```ts
const upload = uploadToS3('avatars')
app.post('/upload', upload.single('avatar'), (req, res) => {
    res.send({msg: 'File uploaded successfully', url: req.file.location})
})
```
## Inspired by
https://medium.com/joor-engineering/setting-up-a-local-aws-s3-environment-for-development-a-step-by-step-guide-573353200d32

## Known issues
For the Node.js snippet above, the resultant file url could be something like `http://bucketName.s3.localhost/key`, which is missing the key! As a work around, you might need to manually construct the url instead of returning `file.location`. A better solution is yet to be found.

## Useful links
- https://docs.localstack.cloud/user-guide/aws/s3/
- https://www.npmjs.com/package/multer
- https://www.npmjs.com/package/multer-s3
