/** @type {import('next').NextConfig} */
const nextConfig = {
  // Remove output: 'export' to enable API routes
  trailingSlash: true,
  images: {
    unoptimized: true
  },
  // Only use assetPrefix for static export, not for API routes
  assetPrefix: process.env.NEXT_EXPORT === 'true' ? 'https://legal.hoiltd.com' : '',
  env: {
    FASTAPI_BASE_URL: 'https://mobot-enterprise-api.redforest-36bfb1e8.eastus.azurecontainerapps.io',
    LEGAL_API_BASE: 'https://mobot-enterprise-api.redforest-36bfb1e8.eastus.azurecontainerapps.io/api/legal',
    STRIPE_PUBLISHABLE_KEY: process.env.STRIPE_PUBLISHABLE_KEY,
    PAYPAL_CLIENT_ID: process.env.PAYPAL_CLIENT_ID
  }
}

module.exports = nextConfig
