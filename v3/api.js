/* 비즈테크 API 클라이언트 v2.0.01 */
const API_BASE = window.location.origin + '/api';

/* 외부 접속 시 모든 /api/ 요청에 X-Mobile-Token 자동 주입 */
(function() {
    const _TOKEN = 'biz-mobile-2024-secure-key';
    const _orig = window.fetch.bind(window);
    window.fetch = function(url, opts) {
        const u = typeof url === 'string' ? url : (url?.url || '');
        if (u.includes('/api/')) {
            opts = Object.assign({}, opts);
            opts.headers = Object.assign({ 'X-Mobile-Token': _TOKEN }, opts.headers || {});
        }
        return _orig(url, opts);
    };
})();

const api = {
  async _fetch(method, path, body) {
    const opts = { method, headers: { 'Content-Type': 'application/json', 'X-Mobile-Token': 'biz-mobile-2024-secure-key' } };
    if (body) opts.body = JSON.stringify(body);
    // GET 요청은 서버 재시작 타이밍에 실패할 수 있어 최대 3회 재시도
    const maxAttempts = method === 'GET' ? 3 : 1;
    for (let attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        const res = await fetch(API_BASE + path, opts);
        const json = await res.json();
        if (!json.ok) throw new Error(json.error || '서버 오류');
        return json.data !== undefined ? json.data : json;
      } catch (e) {
        if (attempt < maxAttempts - 1 && e instanceof TypeError) {
          await new Promise(r => setTimeout(r, 2500));
          continue;
        }
        console.error('[API]', path, e);
        throw e;
      }
    }
  },
  get:    (path)        => api._fetch('GET',    path),
  post:   (path, body)  => api._fetch('POST',   path, body),
  put:    (path, body)  => api._fetch('PUT',    path, body),
  patch:  (path, body)  => api._fetch('PATCH',  path, body),
  delete: (path)        => api._fetch('DELETE', path),

  /* 회사 */
  company: {
    get:    ()     => api.get('/company'),
    update: (data) => api.put('/company', data),
  },

  /* 거래처 */
  clients: {
    list:       (params = {}) => api.get('/clients' + buildQuery(params)),
    get:        (id)           => api.get(`/clients/${id}`),
    add:        (data)         => api.post('/clients', data),
    update:     (id, data)     => api.put(`/clients/${id}`, data),
    remove:     (id, force, cascade) => {
      const qs = force ? '?force=1' : cascade ? '?cascade=1' : '';
      return api.delete(`/clients/${id}${qs}`);
    },
    getDeleted: (params = {}) => api.get('/deleted-clients' + buildQuery(params)),
  },

  /* 제품 */
  items: {
    list:        (params = {}) => api.get('/items' + buildQuery(params)),
    get:         (code)         => api.get(`/items/${code}`),
    add:         (data)         => api.post('/items', data),
    update:      (code, data)   => api.put(`/items/${code}`, data),
    updateStock: (code, val)    => api.patch(`/items/${code}/stock`, {Item_Stock: val}),
    remove:      (code, cascade) => api.delete(`/items/${code}${cascade ? '?cascade=1' : ''}`),
  },

  /* 분류코드 */
  categories: {
    list:   (gubun_code) => api.get('/categories' + (gubun_code ? `?gubun_code=${gubun_code}` : '')),
    groups: ()           => api.get('/categories/group'),
  },

  /* 매입/매출 */
  inven: {
    list:   (params = {}) => api.get('/inven' + buildQuery(params)),
    get:    (ticket)       => api.get(`/inven/${ticket}`),
    add:    (mast, tran)   => api.post('/inven', { mast, tran }),
    remove: (ticket)       => api.delete(`/inven/${ticket}`),
  },

  /* 세금계산서 */
  tax: {
    list: (params = {}) => api.get('/tax' + buildQuery(params)),
    get:  (ticket)       => api.get(`/tax/${ticket}`),
  },

  /* 현금시재 */
  cash: {
    list:   (params = {}) => api.get('/cash' + buildQuery(params)),
    add:    (data)         => api.post('/cash', data),
    update: (no, data)     => api.put(`/cash/${no}`, data),
    remove: (no)           => api.delete(`/cash/${no}`),
  },

  /* 수금/지급 */
  amt: {
    list: (params = {}) => api.get('/amt' + buildQuery(params)),
  },

  /* 재고 */
  stock: {
    list: (params = {}) => api.get('/stock' + buildQuery(params)),
  },

  /* 지출 */
  expense: {
    list:   (params = {}) => api.get('/expense' + buildQuery(params)),
    add:    (data)         => api.post('/expense', data),
    update: (no, data)     => api.put(`/expense/${no}`, data),
    delete: (no)           => api.delete(`/expense/${no}`),
  },

  /* 사원 */
  employees: {
    list:   ()         => api.get('/employees'),
    add:    (data)     => api.post('/employees', data),
    update: (code, d)  => api.put(`/employees/${code}`, d),
    remove: (code)     => api.delete(`/employees/${code}`),
  },

  /* 은행 */
  banks: { list: () => api.get('/banks') },

  /* 코너 */
  conr:  { list: () => api.get('/conr') },

  /* 서버 상태 */
  health: () => api.get('/health'),
};

function buildQuery(params) {
  const q = Object.entries(params).filter(([, v]) => v !== '' && v != null)
    .map(([k, v]) => `${k}=${encodeURIComponent(v)}`).join('&');
  return q ? '?' + q : '';
}

/* 서버 연결 상태 표시 — 연속 2회 실패 시에만 오프라인 표시 */
let _healthFailCount = 0;
async function checkServerStatus() {
  const dot = document.getElementById('server-status-dot');
  const txt = document.getElementById('server-status-text');
  try {
    await api.health();
    _healthFailCount = 0;
    if (dot) { dot.style.background = '#00c853'; dot.title = '서버 연결됨'; }
    if (txt) txt.textContent = '서버 연결됨';
  } catch {
    _healthFailCount++;
    if (_healthFailCount >= 2) {
      if (dot) { dot.style.background = '#f44336'; dot.title = '서버 미연결'; }
      if (txt) txt.textContent = '서버 오프라인';
    }
  }
}

window.api = api;
window.checkServerStatus = checkServerStatus;

document.addEventListener('DOMContentLoaded', () => {
  checkServerStatus();
  setInterval(checkServerStatus, 30000);
});
