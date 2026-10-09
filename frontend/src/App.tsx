import { useCallback, useEffect, useRef, useState } from 'react';
import { ArrowDown, ArrowRight, ArrowUpRight, Check, Cloud, Database, Github, Globe, Layers3, LoaderCircle, MessageSquare, RefreshCw, Send, Server, ShieldCheck, X } from 'lucide-react';

type Message = { id: number; name: string; message: string; created_at: string };
type Availability = 'checking' | 'online' | 'offline';

async function api<T>(path: string, options?: RequestInit): Promise<T> {
  let response: Response;
  try {
    response = await fetch(path, { ...options, signal: AbortSignal.timeout(12000) });
  } catch (error) {
    if (error instanceof DOMException && error.name === 'TimeoutError') {
      throw new Error('The request took too long. Refresh the guestbook before sending again.');
    }
    throw new Error('We couldn’t reach the application. Please check your connection and try again.');
  }
  const body = await response.json().catch(() => null);
  if (!response.ok) throw new Error(body?.error || 'We couldn’t complete that request. Please try again.');
  return body as T;
}

function dateLabel(value: string) {
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? 'Date unavailable' : new Intl.DateTimeFormat(undefined, { month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' }).format(date);
}

function initials(name: string) {
  return name.split(/\s+/).slice(0, 2).map(part => part[0] || '').join('').toUpperCase();
}

export default function App() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [loadError, setLoadError] = useState('');
  const [status, setStatus] = useState<Availability>('checking');
  const [name, setName] = useState('');
  const [message, setMessage] = useState('');
  const [saving, setSaving] = useState(false);
  const [formError, setFormError] = useState('');
  const [success, setSuccess] = useState(false);
  const nameInput = useRef<HTMLInputElement>(null);
  const listRequest = useRef(0);

  const loadMessages = useCallback(async () => {
    const requestId = ++listRequest.current;
    setRefreshing(true);
    try {
      const records = await api<Message[]>('/api/messages');
      if (!Array.isArray(records)) throw new Error('Unexpected response from the guestbook. Please try again.');
      if (requestId === listRequest.current) { setMessages(records); setLoadError(''); }
    } catch (error) {
      if (requestId === listRequest.current) setLoadError(error instanceof Error ? error.message : 'The guestbook is unavailable. Please try again.');
    } finally {
      if (requestId === listRequest.current) { setLoading(false); setRefreshing(false); }
    }
  }, []);

  useEffect(() => { void loadMessages(); }, [loadMessages]);
  useEffect(() => {
    let active = true;
    async function checkHealth() {
      try {
        const result = await api<{ status: string }>('/health');
        if (active) setStatus(result.status === 'ok' ? 'online' : 'offline');
      } catch { if (active) setStatus('offline'); }
    }
    void checkHealth();
    const timer = window.setInterval(checkHealth, 30000);
    return () => { active = false; window.clearInterval(timer); };
  }, []);

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    if (saving) return;
    if (!name.trim() || !message.trim()) { setFormError('Add your name and a message before sending.'); return; }
    setSaving(true); setFormError(''); setSuccess(false);
    try {
      const record = await api<Message>('/api/messages', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ name: name.trim(), message: message.trim() }) });
      ++listRequest.current;
      setMessages(current => [record, ...current.filter(item => item.id !== record.id)].slice(0, 50));
      setLoading(false); setRefreshing(false); setLoadError('');
      setMessage(''); setSuccess(true);
    } catch (error) { setFormError(error instanceof Error ? error.message : 'Your message wasn’t saved. Please try again.'); }
    finally { setSaving(false); }
  }

  function focusForm() { document.getElementById('write')?.scrollIntoView({ behavior: 'smooth', block: 'center' }); nameInput.current?.focus({ preventScroll: true }); }

  return (
    <>
      <a className="skip-link" href="#main">Skip to content</a>
      <header className="site-header">
        <a href="#" className="brand" aria-label="Cloudbook home"><span className="brand-icon"><Cloud size={23} /></span>cloudbook<span className="brand-period">.</span></a>
        <nav aria-label="Main navigation"><a href="#guestbook">Guestbook</a><a href="#architecture">The architecture</a><a className="repo-link" href="https://github.com/Dileesha001/aws-3tier-ha" target="_blank" rel="noreferrer"><Github size={16} /> View source <ArrowUpRight size={14} /></a></nav>
      </header>
      <main id="main">
        <section className="hero">
          <div className="hero-copy">
            <div className="eyebrow"><span className="tiny-dot" /> SMALL MESSAGES. REAL CLOUD INFRASTRUCTURE.</div>
            <h1>A little hello.<br />A whole lot of <em>cloud.</em></h1>
            <p className="hero-description">Leave a thought, share an idea, or just say hello.<br className="desktop-break" /> Every message takes a journey through a three-tier AWS application.</p>
            <div className="hero-actions"><button className="button primary" onClick={focusForm}>Leave a message <ArrowUpRight size={18} /></button><a className="text-link" href="#architecture">See how it works <ArrowDown size={16} /></a></div>
            <div className="built-with"><span>BUILT WITH</span><span>React</span><span>Flask</span><span>PostgreSQL</span><span>AWS</span></div>
          </div>
          <div className="cloud-illustration" aria-label="Messages travel from your browser through the application to the database">
            <div className="illustration-grid" />
            <span className="illustration-label">A MESSAGE, IN MOTION</span>
            <div className="orbit orbit-one" /><div className="orbit orbit-two" />
            <div className="cloud-center"><Cloud strokeWidth={1.15} /><span>the cloud</span></div>
            <div className="floating-card browser-card"><span className="mini-icon orange"><Globe size={21} /></span><div><small>01 / PRESENTATION</small><strong>Your browser</strong></div><span className="card-dot" /></div>
            <div className="floating-card app-card"><span className="mini-icon green"><Server size={21} /></span><div><small>02 / APPLICATION</small><strong>Built to keep going</strong></div><span className="card-dot" /></div>
            <div className="floating-card data-card"><span className="mini-icon gold"><Database size={21} /></span><div><small>03 / DATA</small><strong>A place to remember</strong></div><span className="card-dot" /></div>
            <div className="illustration-footer"><ShieldCheck size={14} /><span>Private app & database subnets</span></div>
          </div>
        </section>

        <section id="guestbook" className="guestbook-section">
          <div className="section-heading"><div><div className="eyebrow">THE GUESTBOOK</div><h2>Good things start with hello.</h2></div><div className={`api-status ${status}`} role="status"><span />{status === 'online' ? 'API available' : status === 'checking' ? 'Checking API' : 'API unavailable'}</div></div>
          <div className="guestbook-grid">
            <aside className="compose-card" id="write">
              <div className="compose-icon"><MessageSquare size={21} /></div><h3>Make yourself at home.</h3><p>Your message becomes a small part of this project. What’s on your mind?</p>
              <form onSubmit={submit}>
                <label htmlFor="name">Your name</label><input ref={nameInput} id="name" autoComplete="name" placeholder="How should we call you?" maxLength={100} required value={name} onChange={e => setName(e.target.value)} disabled={saving} />
                <div className="label-row"><label htmlFor="message">Your message</label><span>{message.length}/500</span></div><textarea id="message" placeholder="A hello, an idea, a little encouragement…" maxLength={500} required rows={5} value={message} onChange={e => { setMessage(e.target.value); setSuccess(false); }} disabled={saving} />
                {formError && <p className="form-error" role="alert">{formError}</p>}
                {success && <div className="success-message" role="status"><Check size={17} /> Your message is saved. Thanks for stopping by!<button type="button" aria-label="Dismiss success message" onClick={() => setSuccess(false)}><X size={14} /></button></div>}
                <button className="button primary send-button" type="submit" disabled={saving}>{saving ? <LoaderCircle className="spin" size={17} /> : <Send size={17} />}{saving ? 'Saving your message…' : 'Send a little hello'}<ArrowRight size={17} /></button>
              </form>
              <p className="public-note"><Globe size={13} /> Messages are public. Please don’t share private information.</p>
            </aside>
            <div className="messages-panel" aria-busy={loading || refreshing}>
              <div className="messages-heading"><h3>Notes from visitors <span>{loading ? '—' : messages.length}</span></h3><button className="refresh-button" disabled={refreshing || saving} onClick={() => void loadMessages()} aria-label="Refresh messages"><RefreshCw size={15} className={refreshing ? 'spin' : ''} /><span>Refresh</span></button></div>
              <p className="messages-caption">A few words, left along the way. Showing the latest 50 messages.</p>
              {loading ? <div className="message-state"><LoaderCircle className="spin" size={25} /><h4>Gathering the hellos…</h4><p>Fetching the latest messages.</p></div> : loadError ? <div className="message-state error-state" role="alert"><Cloud size={31} /><h4>We couldn’t load the guestbook.</h4><p>{loadError}</p><button className="button secondary" onClick={() => void loadMessages()}>Try again <RefreshCw size={15} /></button></div> : messages.length === 0 ? <div className="message-state"><MessageSquare size={29} /><h4>A fresh page, waiting for you.</h4><p>Be the first to leave a little hello.</p><button className="text-link" onClick={focusForm}>Write the first message <ArrowRight size={16} /></button></div> : <div className="message-list">{messages.map((item, index) => <article className="message-card" key={item.id}><div className="message-top"><span className={`avatar avatar-${index % 4}`}>{initials(item.name)}</span><div><h4>{item.name}</h4><time dateTime={new Date(item.created_at).toString() === 'Invalid Date' ? undefined : new Date(item.created_at).toISOString()}>{dateLabel(item.created_at)}</time></div><span className="message-number">#{String(item.id).padStart(3, '0')}</span></div><p>{item.message}</p></article>)}</div>}
              <div className="persistence-note"><Database size={14} /><span>Messages are stored in PostgreSQL, beyond the life of any app instance.</span></div>
            </div>
          </div>
        </section>

        <section className="architecture-section" id="architecture">
          <div className="architecture-intro"><div className="eyebrow">BEHIND THE HELLO</div><h2>Simple on the surface.<br /><em>Resilient underneath.</em></h2><p>A portfolio project exploring how applications stay available when individual servers don’t.</p><a className="text-link" href="https://github.com/Dileesha001/aws-3tier-ha#readme" target="_blank" rel="noreferrer">Explore the project <ArrowUpRight size={16} /></a></div>
          <div className="architecture-details"><div className="flow"><div><Globe size={23} /><strong>Browser</strong><small>React + TypeScript</small></div><ArrowRight className="flow-arrow" size={17} /><div><Layers3 size={23} /><strong>ALB + EC2</strong><small>Nginx + Flask</small></div><ArrowRight className="flow-arrow" size={17} /><div><Database size={23} /><strong>RDS</strong><small>PostgreSQL</small></div></div><div className="architecture-facts"><div><span>01</span><p><strong>Replaceable application instances</strong>Auto Scaling spans two Availability Zones, with ALB health checks.</p></div><div><span>02</span><p><strong>Infrastructure you can repeat</strong>Terraform manages resources. User data starts the app and log agent.</p></div><div><span>03</span><p><strong>Clear, documented boundaries</strong>The current database is Single-AZ. Custom-domain HTTPS is an optional extension.</p></div></div></div>
        </section>
      </main>
      <footer><a className="brand" href="#"><Cloud size={20} /> cloudbook.</a><span>A small application. A real cloud journey.</span><a href="https://github.com/Dileesha001/aws-3tier-ha" target="_blank" rel="noreferrer">Made by Dileesha <ArrowUpRight size={14} /></a></footer>
    </>
  );
}
