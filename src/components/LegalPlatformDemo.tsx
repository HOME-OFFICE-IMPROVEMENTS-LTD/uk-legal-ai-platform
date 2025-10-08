'use client';

import { useState } from 'react';

export default function LegalPlatformDemo() {
  const [activeDemo, setActiveDemo] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<any>(null);
  const [error, setError] = useState<string | null>(null);

  const demoApis = [
    {
      id: 'stripe',
      title: '💳 Stripe Payment API',
      description: 'Create legal subscription',
      endpoint: '/api/payments/stripe/create-subscription',
      method: 'POST',
      sampleData: {
        tier: 'law_firm',
        currency: 'GBP',
        payment_method_id: 'pm_demo_visa',
        userId: 'user_demo_123',
        timestamp: new Date()
      }
    },
    {
      id: 'onionshare',
      title: '🧅 OnionShare Security',
      description: 'Create anonymous file sharing',
      endpoint: '/api/security/onionshare/create-share',
      method: 'POST',
      sampleData: {
        tier: 'enterprise',
        file_names: ['confidential_case.pdf', 'witness_statement.doc'],
        expiry_hours: 24,
        password_protected: true,
        auto_destroy: true,
        userId: 'user_demo_123',
        timestamp: new Date()
      }
    },
    {
      id: 'wireguard',
      title: '🔐 WireGuard VPN',
      description: 'Generate VPN configuration',
      endpoint: '/api/vpn/wireguard/create-config',
      method: 'POST',
      sampleData: {
        tier: 'law_firm',
        vpn_type: 'wireguard',
        client_info: {
          name: 'John Solicitor',
          email: 'john@lawfirm.co.uk',
          firm_name: 'Smith & Associates'
        },
        userId: 'user_demo_123',
        timestamp: new Date()
      }
    },
    {
      id: 'teams',
      title: '📺 Microsoft Teams',
      description: 'Create legal consultation meeting',
      endpoint: '/api/communication/teams/create-meeting',
      method: 'POST',
      sampleData: {
        tier: 'professional',
        system: 'teams',
        action: 'create-meeting',
        participants: ['lawyer@firm.co.uk', 'client@company.co.uk'],
        case_id: 'LC-2024-001',
        recording_required: true,
        userId: 'user_demo_123',
        timestamp: new Date()
      }
    }
  ];

  const handleApiCall = async (api: typeof demoApis[0]) => {
    setActiveDemo(api.id);
    setLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await fetch(api.endpoint, {
        method: api.method,
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(api.sampleData)
      });

      const data = await response.json();
      
      if (!response.ok) {
        throw new Error(data.error || `HTTP ${response.status}`);
      }

      setResult(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  const formatJson = (obj: any) => {
    return JSON.stringify(obj, null, 2);
  };

  return (
    <div className="bg-white rounded-xl p-8 shadow-2xl mt-16">
      <h2 className="text-4xl font-bold text-center text-legal-primary mb-8">
        🧪 Live API Demo
      </h2>
      <p className="text-center text-gray-600 mb-8">
        Test the implemented Legal AI Platform APIs in real-time
      </p>

      <div className="grid md:grid-cols-2 gap-6 mb-8">
        {demoApis.map((api) => (
          <div
            key={api.id}
            className={`border-2 rounded-lg p-4 cursor-pointer transition-all ${
              activeDemo === api.id
                ? 'border-legal-primary bg-blue-50'
                : 'border-gray-200 hover:border-legal-accent'
            }`}
            onClick={() => handleApiCall(api)}
          >
            <h3 className="text-xl font-bold mb-2">{api.title}</h3>
            <p className="text-gray-600 mb-3">{api.description}</p>
            <div className="text-sm text-gray-500">
              <span className="bg-gray-100 px-2 py-1 rounded">
                {api.method} {api.endpoint}
              </span>
            </div>
          </div>
        ))}
      </div>

      {loading && (
        <div className="text-center py-8">
          <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-legal-primary"></div>
          <p className="mt-2 text-gray-600">Calling API...</p>
        </div>
      )}

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
          <h4 className="font-bold text-red-800 mb-2">❌ Error</h4>
          <p className="text-red-700">{error}</p>
        </div>
      )}

      {result && (
        <div className="bg-green-50 border border-green-200 rounded-lg p-4">
          <h4 className="font-bold text-green-800 mb-2">✅ Success</h4>
          <div className="bg-white rounded p-4 overflow-auto max-h-96">
            <pre className="text-sm text-gray-800 whitespace-pre-wrap">
              {formatJson(result)}
            </pre>
          </div>
        </div>
      )}

      {!loading && !result && !error && (
        <div className="text-center py-8 text-gray-500">
          <p>Click on any API above to test the implementation</p>
        </div>
      )}
    </div>
  );
}