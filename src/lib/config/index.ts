// Configuration loader for Legal AI Platform
import { PaymentConfig, OnionShareConfig, VPNIntegration, CommunicationSystem } from '../types';
import paymentConfig from '../integrations/payment-config.json';
import onionShareConfig from '../security/onionshare-config.json';
import vpnConfig from '../vpn/vpn-integrations.json';
import communicationConfig from '../communication/communication-systems.json';

export class ConfigManager {
  private static instance: ConfigManager;
  
  private constructor() {}
  
  public static getInstance(): ConfigManager {
    if (!ConfigManager.instance) {
      ConfigManager.instance = new ConfigManager();
    }
    return ConfigManager.instance;
  }
  
  public getPaymentConfig(): PaymentConfig {
    return paymentConfig as PaymentConfig;
  }
  
  public getOnionShareConfig(): OnionShareConfig {
    return onionShareConfig as OnionShareConfig;
  }
  
  public getVPNConfig(): Record<string, VPNIntegration> {
    return vpnConfig as Record<string, VPNIntegration>;
  }
  
  public getCommunicationConfig(): Record<string, CommunicationSystem> {
    return communicationConfig as Record<string, CommunicationSystem>;
  }
  
  public getStripeConfig() {
    return this.getPaymentConfig().stripe;
  }
  
  public getPayPalConfig() {
    return this.getPaymentConfig().paypal;
  }
  
  public getFOSSBillingConfig() {
    return this.getPaymentConfig().fossbilling;
  }
  
  public getWireGuardConfig(): VPNIntegration {
    return this.getVPNConfig().wireguard;
  }
  
  public getTailscaleConfig(): VPNIntegration {
    return this.getVPNConfig().tailscale;
  }
  
  public getOpenVPNConfig(): VPNIntegration {
    return this.getVPNConfig().openvpn;
  }
  
  public get3CXConfig(): CommunicationSystem {
    return this.getCommunicationConfig()['3cx'];
  }
  
  public getTeamsConfig(): CommunicationSystem {
    return this.getCommunicationConfig().ms_teams;
  }
  
  // Helper method to validate tier access
  public validateTierAccess(tier: string, feature: string): boolean {
    const configs = [
      this.getOnionShareConfig(),
      ...Object.values(this.getVPNConfig()),
      ...Object.values(this.getCommunicationConfig())
    ];
    
    for (const config of configs) {
      if (config.pricing && config.pricing.included_in_tiers.includes(tier)) {
        return true;
      }
    }
    
    return false;
  }
  
  // Get pricing for a specific tier
  public getTierPricing(tier: string): { gbp: number; usd: number } | null {
    const stripeConfig = this.getStripeConfig();
    const tierConfig = stripeConfig.legal_tiers[tier];
    
    if (!tierConfig) {
      return null;
    }
    
    return {
      gbp: tierConfig.price_gbp,
      usd: tierConfig.price_usd
    };
  }
}