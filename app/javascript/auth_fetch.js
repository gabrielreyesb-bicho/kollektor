// When the session expires, Devise often answers fetch/XHR with a redirect to the sign-in page.
// The browser follows it and you still get response.ok + HTML — Stimulus code keeps "working"
// but shows errors or spins forever. Force a full navigation so the user sees the real sign-in UI.

function signInPath() {
  const meta = document.querySelector('meta[name="user-sign-in-path"]')
  return (meta && meta.content) || "/users/sign_in"
}

function isSignInUrl(urlString) {
  try {
    const expected = signInPath()
    const u = new URL(urlString, window.location.origin)
    return u.pathname === expected || u.pathname === `${expected}/`
  } catch {
    return false
  }
}

const nativeFetch = window.fetch.bind(window)

window.fetch = async function authAwareFetch(input, init) {
  const response = await nativeFetch(input, init)

  if (response.status === 401) {
    window.location.assign(new URL(signInPath(), window.location.origin).href)
    return response
  }

  if (response.redirected && isSignInUrl(response.url)) {
    const dest = new URL(response.url)
    if (dest.origin === window.location.origin) {
      window.location.assign(response.url)
    }
    return response
  }

  return response
}
