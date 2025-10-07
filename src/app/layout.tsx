import './globals.css'

export const metadata = {
  title: 'UK Legal AI Platform - Revolutionary Legal Technology',
  description: 'Advanced Legal AI platform with OnionShare Tor integration, enterprise security, and 23 specialized AI models for UK solicitors.',
  keywords: 'legal AI, UK solicitors, law firms, OnionShare, Tor integration, legal technology, AI lawyers',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className="font-sans">{children}</body>
    </html>
  )
}
