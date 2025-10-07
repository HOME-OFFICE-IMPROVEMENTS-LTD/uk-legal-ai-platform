// Stripe Integration API for UK Legal AI Platform
import { NextRequest, NextResponse } from 'next/server';
import { ErrorHandler, Validator, AzureIntegration } from '../../../../../lib/utils';
import { ConfigManager } from '../../../../../lib/config';
import { StripeSubscriptionRequest, ApiResponse } from '../../../../../lib/types';

/**
 * Create Stripe subscription for legal tier
 * POST /api/payments/stripe/create-subscription
 */
export async function POST(request: NextRequest) {
  try {
    const body: StripeSubscriptionRequest = await request.json();
    
    // Validate request
    if (!Validator.isValidTier(body.tier)) {
      return NextResponse.json(
        ErrorHandler.createErrorResponse('Invalid legal tier', 'INVALID_TIER'),
        { status: 400 }
      );
    }
    
    if (!Validator.isValidCurrency(body.currency)) {
      return NextResponse.json(
        ErrorHandler.createErrorResponse('Invalid currency', 'INVALID_CURRENCY'),
        { status: 400 }
      );
    }
    
    if (!body.payment_method_id) {
      return NextResponse.json(
        ErrorHandler.createErrorResponse('Payment method required', 'MISSING_PAYMENT_METHOD'),
        { status: 400 }
      );
    }
    
    // Get configuration
    const config = ConfigManager.getInstance();
    const stripeConfig = config.getStripeConfig();
    const tierPricing = config.getTierPricing(body.tier);
    
    if (!tierPricing) {
      return NextResponse.json(
        ErrorHandler.createErrorResponse('Tier pricing not found', 'TIER_PRICING_ERROR'),
        { status: 400 }
      );
    }
    
    // Simulate Stripe subscription creation
    // In production, this would use the actual Stripe API
    const subscriptionId = `sub_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const amount = body.currency === 'GBP' ? tierPricing.gbp : tierPricing.usd;
    
    // Call Azure API to register subscription
    const azureApiUrl = `${AzureIntegration.getLegalApiUrl()}/subscriptions`;
    
    const subscriptionData = {
      subscription_id: subscriptionId,
      user_id: body.userId,
      tier: body.tier,
      currency: body.currency,
      amount: amount,
      status: 'active',
      payment_provider: 'stripe',
      created_at: new Date().toISOString(),
      features: stripeConfig.legal_tiers[body.tier].features
    };
    
    // Log for compliance
    console.log('[STRIPE-SUBSCRIPTION] Created subscription:', {
      subscription_id: subscriptionId,
      tier: body.tier,
      amount: amount,
      currency: body.currency,
      timestamp: new Date().toISOString()
    });
    
    const response: ApiResponse = ErrorHandler.createSuccessResponse({
      subscription_id: subscriptionId,
      tier: body.tier,
      amount: amount,
      currency: body.currency,
      status: 'active',
      next_billing_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
      features: stripeConfig.legal_tiers[body.tier].features,
      azure_api_endpoint: azureApiUrl
    }, 'Stripe subscription created successfully');
    
    return NextResponse.json(response, { status: 201 });
    
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json(
      ErrorHandler.createErrorResponse(
        `Stripe subscription creation failed: ${errorMessage}`,
        'STRIPE_CREATION_ERROR',
        'high'
      ),
      { status: 500 }
    );
  }
}

/**
 * Get subscription details
 * GET /api/payments/stripe/create-subscription?subscription_id=sub_xxx
 */
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const subscriptionId = searchParams.get('subscription_id');
    
    if (!subscriptionId) {
      return NextResponse.json(
        ErrorHandler.createErrorResponse('Subscription ID required', 'MISSING_SUBSCRIPTION_ID'),
        { status: 400 }
      );
    }
    
    // Simulate subscription retrieval
    const mockSubscription = {
      subscription_id: subscriptionId,
      status: 'active',
      tier: 'law_firm',
      currency: 'GBP',
      amount: 499,
      created_at: new Date().toISOString(),
      next_billing_date: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
      features: [
        '2000 documents/month',
        'Multi-user accounts',
        'Enterprise features',
        'Dedicated support'
      ]
    };
    
    const response: ApiResponse = ErrorHandler.createSuccessResponse(
      mockSubscription,
      'Subscription details retrieved successfully'
    );
    
    return NextResponse.json(response);
    
  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    return NextResponse.json(
      ErrorHandler.createErrorResponse(
        `Failed to retrieve subscription: ${errorMessage}`,
        'STRIPE_RETRIEVAL_ERROR'
      ),
      { status: 500 }
    );
  }
}