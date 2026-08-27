(() => {
  const messagesEl = document.getElementById('messages');
  const formEl = document.getElementById('chat-form');
  const inputEl = document.getElementById('chat-input');
  const sendBtn = document.getElementById('send-btn');
  const statusEl = document.getElementById('status');
  const newConversationBtn = document.getElementById('new-conversation');
  const template = document.getElementById('message-template');

  let conversationId = null;
  let sending = false;

  function setStatus(kind, text) {
    statusEl.className = `status status-${kind}`;
    statusEl.textContent = text;
  }

  function addMessage({ role, text = '', raw = false }) {
    const node = template.content.cloneNode(true);
    const messageEl = node.querySelector('.message');
    const avatarEl = node.querySelector('.avatar');
    const bubbleEl = node.querySelector('.bubble');
    const rawToggle = node.querySelector('.raw-toggle');
    const rawLog = node.querySelector('.raw-log');

    messageEl.classList.add(`from-${role}`);
    avatarEl.textContent = role === 'user' ? 'You' : role === 'system' ? '' : 'IT';
    bubbleEl.textContent = text;

    messagesEl.appendChild(node);
    const appended = messagesEl.lastElementChild;
    messagesEl.scrollTop = messagesEl.scrollHeight;

    return {
      root: appended,
      bubbleEl: appended.querySelector('.bubble'),
      rawToggle: appended.querySelector('.raw-toggle'),
      rawLog: appended.querySelector('.raw-log'),
    };
  }

  function scrollToBottom() {
    messagesEl.scrollTop = messagesEl.scrollHeight;
  }

  // Best-effort extraction of incremental text from a streamed JSON chunk.
  // The exact wire format wasn't verified against a live Genie API call, so
  // this checks several common shapes; unmatched chunks show up in the raw
  // log panel underneath each assistant message for debugging.
  function extractText(obj) {
    if (obj == null) return null;
    if (typeof obj === 'string') return obj;

    const candidates = [
      obj.delta,
      obj.text,
      obj.content,
      obj.message,
      obj.chunk,
      obj.output_text,
      obj?.data?.content,
      obj?.data?.text,
      obj?.message?.content,
      obj?.delta?.content,
      obj?.delta?.text,
      obj?.choices?.[0]?.delta?.content,
      obj?.choices?.[0]?.text,
    ];

    for (const candidate of candidates) {
      if (typeof candidate === 'string') return candidate;
    }
    return null;
  }

  async function startConversation() {
    setStatus('connecting', 'Connecting…');
    try {
      const res = await fetch('/api/start-conversation', { method: 'POST' });
      const data = await res.json().catch(() => ({}));
      if (!res.ok) {
        throw new Error(data.error || data.message || `HTTP ${res.status}`);
      }
      conversationId = data.conversation_id || data.conversationId || data.id || data?.data?.conversation_id;
      if (!conversationId) {
        throw new Error('Genie API did not return a conversation_id (see console for raw response)');
      }
      setStatus('connected', 'Connected');
      console.info('Genie conversation started:', data);
      return true;
    } catch (err) {
      setStatus('error', 'Connection failed');
      addMessage({ role: 'system', text: `Could not start a conversation: ${err.message}` });
      console.error(err);
      return false;
    }
  }

  async function sendMessage(text) {
    if (!conversationId) {
      const ok = await startConversation();
      if (!ok) return;
    }

    addMessage({ role: 'user', text });

    const assistantMsg = addMessage({ role: 'assistant', text: '' });
    assistantMsg.bubbleEl.classList.add('typing-dots');
    let assistantText = '';
    let rawLogText = '';

    sending = true;
    sendBtn.disabled = true;

    try {
      const res = await fetch('/api/send-message', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ conversationId, message: text }),
      });

      if (!res.ok || !res.body) {
        const errBody = await res.text().catch(() => '');
        throw new Error(`HTTP ${res.status} ${errBody}`.trim());
      }

      const reader = res.body.getReader();
      const decoder = new TextDecoder();
      let buffer = '';
      let receivedAny = false;

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunkStr = decoder.decode(value, { stream: true });
        buffer += chunkStr;
        rawLogText += chunkStr;

        // SSE events are separated by a blank line; also tolerate plain
        // newline-delimited JSON in case the API isn't strict SSE.
        const events = buffer.split(/\n\n/);
        buffer = events.pop() ?? '';

        for (const evt of events) {
          for (const line of evt.split('\n')) {
            const trimmed = line.trim();
            if (!trimmed) continue;
            const payload = trimmed.startsWith('data:') ? trimmed.slice(5).trim() : trimmed;
            if (!payload || payload === '[DONE]') continue;

            let parsed = null;
            try {
              parsed = JSON.parse(payload);
            } catch {
              // Not JSON — treat as raw text delta.
              assistantText += payload;
              receivedAny = true;
              continue;
            }

            const piece = extractText(parsed);
            if (piece) {
              assistantText += piece;
              receivedAny = true;
            }
          }
        }

        if (receivedAny) {
          assistantMsg.bubbleEl.classList.remove('typing-dots');
          assistantMsg.bubbleEl.textContent = assistantText;
          scrollToBottom();
        }
      }

      // Flush anything left in the buffer after the stream closes.
      if (buffer.trim()) {
        const payload = buffer.trim().replace(/^data:\s*/, '');
        if (payload && payload !== '[DONE]') {
          try {
            const parsed = JSON.parse(payload);
            const piece = extractText(parsed);
            if (piece) assistantText += piece;
          } catch {
            assistantText += payload;
          }
        }
      }

      assistantMsg.bubbleEl.classList.remove('typing-dots');
      if (!assistantText) {
        assistantText = receivedAny
          ? ''
          : '(No readable text found in the response — click "View raw" below to see exactly what the Genie API returned.)';
      }
      assistantMsg.bubbleEl.textContent = assistantText;

      if (rawLogText) {
        assistantMsg.rawToggle.hidden = false;
        assistantMsg.rawLog.textContent = rawLogText;
        assistantMsg.rawToggle.addEventListener('click', () => {
          const isHidden = assistantMsg.rawLog.hidden;
          assistantMsg.rawLog.hidden = !isHidden;
          assistantMsg.rawToggle.textContent = isHidden ? 'Hide raw' : 'View raw';
        });
      }
    } catch (err) {
      assistantMsg.bubbleEl.classList.remove('typing-dots');
      assistantMsg.root.classList.add('error');
      assistantMsg.bubbleEl.textContent = `Something went wrong: ${err.message}`;
      console.error(err);
    } finally {
      sending = false;
      sendBtn.disabled = false;
      scrollToBottom();
    }
  }

  formEl.addEventListener('submit', (e) => {
    e.preventDefault();
    const text = inputEl.value.trim();
    if (!text || sending) return;
    inputEl.value = '';
    inputEl.style.height = 'auto';
    sendMessage(text);
  });

  inputEl.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      formEl.requestSubmit();
    }
  });

  inputEl.addEventListener('input', () => {
    inputEl.style.height = 'auto';
    inputEl.style.height = `${Math.min(inputEl.scrollHeight, 140)}px`;
  });

  newConversationBtn.addEventListener('click', async () => {
    conversationId = null;
    messagesEl.innerHTML = '';
    addMessage({ role: 'system', text: 'Starting a new conversation…' });
    const ok = await startConversation();
    if (ok) {
      messagesEl.innerHTML = '';
      addMessage({ role: 'system', text: 'New conversation started.' });
    }
  });

  startConversation().then((ok) => {
    if (ok) {
      addMessage({
        role: 'system',
        text: 'Connected to IT Support. Ask a question to get started.',
      });
    }
  });
})();
