// Removed Google Fonts dependency for offline compatibility
import LegalPlatformDemo from '../components/LegalPlatformDemo';

export default function Home() {
  return (
    <main className="min-h-screen bg-gradient-to-br from-legal-primary to-legal-secondary font-sans">
      <div className="container mx-auto px-4 py-16">
        {/* Hero Section */}
        <div className="text-center text-white mb-16">
          <h1 className="text-6xl font-bold mb-6">
            🎯 UK Legal AI Platform
          </h1>
          <p className="text-2xl mb-8 opacity-90">
            Revolutionary Legal AI with OnionShare Tor Integration
          </p>
          <div className="flex justify-center space-x-4">
            <span className="bg-white/20 px-4 py-2 rounded-full">🔒 Ultra-Secure</span>
            <span className="bg-white/20 px-4 py-2 rounded-full">🧅 Tor Integration</span>
            <span className="bg-white/20 px-4 py-2 rounded-full">⚡ 23 AI Models</span>
          </div>
        </div>

        {/* Features Grid */}
        <div className="grid md:grid-cols-3 gap-8 mb-16">
          <div className="bg-white rounded-lg p-6 shadow-xl">
            <h3 className="text-2xl font-bold text-legal-primary mb-4">💳 Secure Payments</h3>
            <p className="text-gray-600">Stripe + PayPal + FOSSBilling integration with enterprise-grade security</p>
          </div>
          
          <div className="bg-white rounded-lg p-6 shadow-xl">
            <h3 className="text-2xl font-bold text-onion-purple mb-4">🧅 OnionShare Security</h3>
            <p className="text-gray-600">Anonymous document sharing via Tor network for ultimate privacy</p>
          </div>
          
          <div className="bg-white rounded-lg p-6 shadow-xl">
            <h3 className="text-2xl font-bold text-legal-accent mb-4">🔐 VPN Integration</h3>
            <p className="text-gray-600">WireGuard + Tailscale + OpenVPN for secure communications</p>
          </div>
        </div>

        {/* Pricing Tiers */}
        <div className="bg-white rounded-xl p-8 shadow-2xl">
          <h2 className="text-4xl font-bold text-center text-legal-primary mb-8">Pricing Tiers</h2>
          <div className="grid md:grid-cols-4 gap-6">
            <div className="border border-gray-200 rounded-lg p-6 text-center">
              <h3 className="text-xl font-bold mb-2">Basic Legal AI</h3>
              <p className="text-3xl font-bold text-legal-primary mb-4">£79/month</p>
              <ul className="text-sm text-gray-600 space-y-2">
                <li>100 documents/month</li>
                <li>23 specialized LLMs</li>
                <li>Basic contract analysis</li>
                <li>Email support</li>
              </ul>
            </div>
            
            <div className="border border-gray-200 rounded-lg p-6 text-center">
              <h3 className="text-xl font-bold mb-2">Professional</h3>
              <p className="text-3xl font-bold text-legal-primary mb-4">£199/month</p>
              <ul className="text-sm text-gray-600 space-y-2">
                <li>500 documents/month</li>
                <li>Advanced analysis</li>
                <li>Legal research tools</li>
                <li>Priority support</li>
              </ul>
            </div>
            
            <div className="border border-legal-accent border-2 rounded-lg p-6 text-center relative">
              <div className="absolute -top-3 left-1/2 transform -translate-x-1/2 bg-legal-accent text-white px-3 py-1 rounded-full text-sm">Most Popular</div>
              <h3 className="text-xl font-bold mb-2">Law Firm</h3>
              <p className="text-3xl font-bold text-legal-primary mb-4">£499/month</p>
              <ul className="text-sm text-gray-600 space-y-2">
                <li>2000 documents/month</li>
                <li>Multi-user accounts</li>
                <li>Enterprise features</li>
                <li>Dedicated support</li>
              </ul>
            </div>
            
            <div className="border border-onion-purple border-2 rounded-lg p-6 text-center relative">
              <div className="absolute -top-3 left-1/2 transform -translate-x-1/2 bg-onion-purple text-white px-3 py-1 rounded-full text-sm">🧅 Tor Included</div>
              <h3 className="text-xl font-bold mb-2">Enterprise</h3>
              <p className="text-3xl font-bold text-legal-primary mb-4">£999/month</p>
              <ul className="text-sm text-gray-600 space-y-2">
                <li>Unlimited everything</li>
                <li>OnionShare Tor</li>
                <li>Custom AI training</li>
                <li>24/7 support</li>
              </ul>
            </div>
          </div>
        </div>

        {/* Interactive API Demo */}
        <LegalPlatformDemo />

        {/* CTA Section */}
        <div className="text-center mt-16">
          <button className="bg-legal-accent hover:bg-yellow-500 text-white font-bold py-4 px-8 rounded-full text-xl transition-colors">
            �� Start Free Trial
          </button>
          <p className="text-white mt-4 opacity-90">
            Join the legal AI revolution • No setup fees • Cancel anytime
          </p>
        </div>
      </div>
    </main>
  )
}
