// Legal AI Platform TypeScript Types
// Generated from JSON configurations for enterprise MoBot architecture

export interface LegalTier {
  price_gbp: number;
  price_usd: number;
  features: string[];
}

export interface PaymentConfig {
  stripe: {
    publishable_key: string;
    webhook_endpoint: string;
    supported_currencies: string[];
    legal_tiers: Record<string, LegalTier>;
  };
  paypal: {
    client_id: string;
    webhook_endpoint: string;
    supported_currencies: string[];
  };
  fossbilling: {
    api_endpoint: string;
    webhook_endpoint: string;
    subscription_management: boolean;
  };
}

export interface VPNIntegration {
  features: string[];
  legal_benefits: string[];
  api_endpoints: string[];
  pricing: {
    included_in_tiers: string[];
    standalone_price_gbp?: number;
    addon_price_gbp?: number;
  };
}

export interface OnionShareConfig {
  security_features: {
    anonymous_uploads: boolean;
    tor_network_only: boolean;
    self_destructing_shares: boolean;
    no_ip_logging: boolean;
    end_to_end_encryption: boolean;
  };
  legal_use_cases: string[];
  pricing: {
    addon_price_gbp: number;
    addon_price_usd: number;
    included_in_tiers: string[];
    available_for: string[];
  };
  technical_requirements: {
    tor_browser_required: boolean;
    onionshare_cli: boolean;
    secure_storage: boolean;
    automated_cleanup: boolean;
    expiry_hours_default: number;
    max_upload_size_mb: number;
  };
  compliance_features: string[];
}

export interface CommunicationSystem {
  legal_features: string[];
  compliance_features: string[];
  api_endpoints: string[];
  pricing: {
    included_in_tiers: string[];
    addon_price_gbp?: number;
    standalone_price_gbp?: number;
  };
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface LegalPlatformRequest {
  userId?: string;
  tier: string;
  timestamp: Date;
}

// Stripe-specific types
export interface StripeSubscriptionRequest extends LegalPlatformRequest {
  tier: 'basic' | 'professional' | 'law_firm' | 'enterprise';
  currency: 'GBP' | 'USD' | 'EUR';
  payment_method_id: string;
}

export interface StripeWebhookEvent {
  id: string;
  type: string;
  data: any;
  created: number;
}

// VPN Configuration types
export interface VPNConfigRequest extends LegalPlatformRequest {
  vpn_type: 'wireguard' | 'tailscale' | 'openvpn';
  client_info: {
    name: string;
    email: string;
    firm_name?: string;
  };
}

export interface WireGuardConfig {
  private_key: string;
  public_key: string;
  endpoint: string;
  allowed_ips: string[];
  dns?: string[];
}

// OnionShare types
export interface OnionShareRequest extends LegalPlatformRequest {
  file_names: string[];
  expiry_hours?: number;
  password_protected?: boolean;
  auto_destroy?: boolean;
}

export interface OnionShareResponse {
  onion_url: string;
  access_key: string;
  expiry_timestamp: Date;
  upload_urls: string[];
}

// Communication system types
export interface CommunicationRequest extends LegalPlatformRequest {
  system: '3cx' | 'teams';
  action: 'initiate-call' | 'record-consultation' | 'create-meeting' | 'schedule-consultation';
  participants: string[];
  case_id?: string;
  recording_required?: boolean;
}

// Error types for enterprise compliance
export interface LegalPlatformError extends Error {
  code: string;
  severity: 'low' | 'medium' | 'high' | 'critical';
  compliance_logged: boolean;
  audit_trail_id?: string;
}