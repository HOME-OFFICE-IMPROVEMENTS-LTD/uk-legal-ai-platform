// Utility functions for Legal AI Platform
import { LegalPlatformError, ApiResponse } from '../types';

export class ErrorHandler {
  /**
   * Create a standardized error response for Legal Platform APIs
   */
  static createErrorResponse(
    error: string,
    code: string = 'GENERIC_ERROR',
    severity: 'low' | 'medium' | 'high' | 'critical' = 'medium'
  ): ApiResponse {
    const legalError: LegalPlatformError = {
      name: 'LegalPlatformError',
      message: error,
      code,
      severity,
      compliance_logged: true,
      audit_trail_id: generateAuditId()
    };

    // Log error for compliance and audit trail
    console.error(`[LEGAL-PLATFORM-ERROR] [${severity.toUpperCase()}] ${code}: ${error}`, {
      audit_trail_id: legalError.audit_trail_id,
      timestamp: new Date().toISOString()
    });

    return {
      success: false,
      error: error,
      message: `Legal Platform Error: ${error}`
    };
  }

  /**
   * Create a success response
   */
  static createSuccessResponse<T>(data: T, message?: string): ApiResponse<T> {
    return {
      success: true,
      data,
      message
    };
  }
}

export class Validator {
  /**
   * Validate legal tier
   */
  static isValidTier(tier: string): boolean {
    const validTiers = ['basic', 'professional', 'law_firm', 'enterprise'];
    return validTiers.includes(tier);
  }

  /**
   * Validate currency
   */
  static isValidCurrency(currency: string): boolean {
    const validCurrencies = ['GBP', 'USD', 'EUR'];
    return validCurrencies.includes(currency.toUpperCase());
  }

  /**
   * Validate email format
   */
  static isValidEmail(email: string): boolean {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  }

  /**
   * Validate VPN type
   */
  static isValidVPNType(vpnType: string): boolean {
    const validTypes = ['wireguard', 'tailscale', 'openvpn'];
    return validTypes.includes(vpnType);
  }

  /**
   * Validate communication system
   */
  static isValidCommunicationSystem(system: string): boolean {
    const validSystems = ['3cx', 'teams'];
    return validSystems.includes(system);
  }

  /**
   * Validate file size for OnionShare uploads
   */
  static isValidFileSize(sizeMB: number, maxSizeMB: number = 100): boolean {
    return sizeMB > 0 && sizeMB <= maxSizeMB;
  }

  /**
   * Validate expiry hours for OnionShare
   */
  static isValidExpiryHours(hours: number): boolean {
    return hours > 0 && hours <= 168; // Max 1 week
  }
}

export class SecurityUtils {
  /**
   * Generate secure random string for API keys
   */
  static generateSecureToken(length: number = 32): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  }

  /**
   * Generate OnionShare compatible URL
   */
  static generateOnionUrl(): string {
    // Simulated onion URL generation (in real implementation, would use actual Tor)
    const onionHash = SecurityUtils.generateSecureToken(16).toLowerCase();
    return `http://${onionHash}.onion`;
  }

  /**
   * Hash sensitive data for compliance logging
   */
  static hashForCompliance(data: string): string {
    // Simple hash for demo (use proper crypto in production)
    let hash = 0;
    for (let i = 0; i < data.length; i++) {
      const char = data.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    return Math.abs(hash).toString(16);
  }

  /**
   * Sanitize user input for logging
   */
  static sanitizeForLog(input: any): any {
    if (typeof input === 'string') {
      return input.replace(/[<>&"']/g, '');
    }
    if (typeof input === 'object' && input !== null) {
      const sanitized: any = {};
      for (const [key, value] of Object.entries(input)) {
        // Don't log sensitive fields
        if (['password', 'token', 'key', 'secret'].some(sensitive => 
          key.toLowerCase().includes(sensitive))) {
          sanitized[key] = '[REDACTED]';
        } else {
          sanitized[key] = SecurityUtils.sanitizeForLog(value);
        }
      }
      return sanitized;
    }
    return input;
  }
}

export class AzureIntegration {
  /**
   * Get Azure Container Apps base URL from environment
   */
  static getBaseApiUrl(): string {
    return process.env.FASTAPI_BASE_URL || 
           'https://mobot-enterprise-api.redforest-36bfb1e8.eastus.azurecontainerapps.io';
  }

  /**
   * Get legal-specific API base URL
   */
  static getLegalApiUrl(): string {
    return process.env.LEGAL_API_BASE || 
           'https://mobot-enterprise-api.redforest-36bfb1e8.eastus.azurecontainerapps.io/api/legal';
  }

  /**
   * Create headers for Azure API calls
   */
  static createApiHeaders(includeAuth: boolean = true): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'User-Agent': 'UK-Legal-AI-Platform/1.0.0',
      'X-Platform': 'mobot-enterprise'
    };

    if (includeAuth) {
      // In production, this would use proper JWT tokens
      headers['Authorization'] = 'Bearer legal-platform-token';
    }

    return headers;
  }
}

/**
 * Generate unique audit trail ID for compliance
 */
function generateAuditId(): string {
  const timestamp = Date.now().toString(36);
  const random = Math.random().toString(36).substr(2, 9);
  return `audit_${timestamp}_${random}`;
}

/**
 * Format currency for display
 */
export function formatCurrency(amount: number, currency: string): string {
  const formatter = new Intl.NumberFormat('en-GB', {
    style: 'currency',
    currency: currency.toUpperCase()
  });
  return formatter.format(amount);
}

/**
 * Calculate addon pricing for tiers
 */
export function calculateAddonPrice(baseTier: string, addonPrice: number): number {
  const tierMultipliers: Record<string, number> = {
    'basic': 1.0,
    'professional': 0.8,
    'law_firm': 0.6,
    'enterprise': 0.4
  };
  
  const multiplier = tierMultipliers[baseTier] || 1.0;
  return Math.round(addonPrice * multiplier);
}