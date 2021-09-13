import classNames from "classnames";
import { useEffect, useReducer, useState } from "react";
import * as React from "react";
import "./../assets/scss/Main.scss";
import api from "../utils/api";
import { isAuthenticated } from "../utils/auth";
import { RouteHandler } from "./topLevelRouteHandlers";

const initialState = { pagination: null, urls: [], busy: false };

const reducer = (state, action) => {
  switch (action.type) {
    case "fetch":
      return { ...state, pagination: action.pagination, urls: action.urls };
    case "busy":
      return { ...state, busy: true };
    case "unbusy":
      return { ...state, busy: false };
    case "added":
      return { ...state, urls: [...state.urls, action.url] };
    default:
      throw new Error();
  }
};

const UrlsTab = ({ onAuthError }: { onAuthError?: () => void }) => {
  const [state, dispatch] = useReducer(reducer, initialState);
  const fetch = async (page: number, perPage: number) => {
    try {
      dispatch({ type: "busy" });
      const resp = await api.fetchUrls(page, perPage);
      if (resp instanceof Response && resp.status === 401) {
        onAuthError?.();
      }
      if (resp?.data) {
        dispatch({
          type: "fetch",
          urls: resp.data.urls,
          pagination: resp.data.pagination,
        });
      }
    } finally {
      dispatch({ type: "unbusy" });
    }
  };

  useEffect(() => {
    fetch(1, 25);
  }, []);

  return (
    <>
      <UrlCreationBar onAdded={(url) => dispatch({ type: "added", url })} />
      <div className="urls">
        {state.busy && !state.urls.length && (
          <div className="urls-fetching-placeholder">
            Fetching Your Links...
          </div>
        )}
        {!state.busy && !state.urls.length && (
          <div className="no-urls-placeholder">No links shortened yet</div>
        )}
        {state.urls.length > 0 && (
          <div className="url-data-row">
            <div className="url-data-heading">Link</div>
            <div className="url-data-heading">Shortened Link</div>
            <div className="url-data-heading">Times followed</div>
          </div>
        )}
        {state.urls.map((url: Url, index: number) => {
          return (
            <div className="url-data-row" key={index}>
              <div className="url-data-column">{url.url}</div>
              <div className="url-data-column">{url.shortenedUrl}</div>
              <div className="url-data-column">{url.timesFollowed}</div>
            </div>
          );
        })}
      </div>
    </>
  );
};

const Error = ({ error, className }: { error: string; className?: string }) => {
  if (!error) {
    return null;
  }
  return (
    <div className={classNames("generic-error", className)}>
      <span>{error}</span>
    </div>
  );
};

type Url = {
  url: string;
  shortenedUrl: string;
  timesFollowed: number;
};

const defaultError = "Something went wrong, please try again";

const UrlCreationBar = ({ onAdded }: { onAdded?: (url: Url) => void }) => {
  const [url, setUrl] = useState("");
  const [error, setError] = useState("");
  const [shortenedUrl, setShortenedUrl] = useState("");
  const [inProgress, setInProgress] = useState(false);
  const fullShortenedUrl = `${APP_URL}/${shortenedUrl}`;
  const disabled = !url || inProgress;
  const createUrl = async (e) => {
    e.preventDefault();
    if (disabled) {
      return;
    }
    setError("");
    try {
      setInProgress(true);
      const result = await api.createUrl({ url });
      if (result?.data && result.data?.url?.shortenedUrl) {
        onAdded?.(result.data.url);
        setShortenedUrl(result?.data.url?.shortenedUrl);
      }
    } catch (e) {
      if (e instanceof Response) {
        const json = await e.json();
        if (json.messages) {
          setError(json.messages.join("; "));
        } else {
          setError(defaultError);
        }
      } else {
        setError(defaultError);
      }
    } finally {
      setInProgress(false);
    }
  };
  return (
    <>
      <h2 className="main-heading">Shorten any link!</h2>
      <div className="url-creation">
        <form className="url-creation-form" onSubmit={createUrl}>
          <input
            type="text"
            value={url}
            placeholder="Shorten your link"
            onChange={(e) => setUrl(e.target.value)}
            className="url-creation-input"
          />
          <button
            type="submit"
            disabled={disabled}
            className={classNames("url-creation-submit", {
              "url-creation-submit--disabled": disabled,
            })}
          >
            Shorten
          </button>
        </form>
        {shortenedUrl && (
          <div className="url-creation-shortened-url">
            Your shortened url is:{" "}
            <a
              target="_blank"
              className="shortened-url"
              href={fullShortenedUrl}
            >
              {fullShortenedUrl}
            </a>
          </div>
        )}
        <Error error={error} />
      </div>
    </>
  );
};

type LoginSignupParams = {
  onSuccess?: () => void;
};

const SignupForm = ({ onSuccess }: LoginSignupParams) => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [inProgress, setInProgress] = useState(false);
  const [error, setError] = useState("");
  const disabled = !(email && password && !inProgress);
  const signup = async (e) => {
    e.preventDefault();
    if (disabled) {
      return;
    }
    try {
      setInProgress(true);
      await api.signUp({ email, password });
      onSuccess?.();
    } catch (e) {
      if (e instanceof Response) {
        const json = await e.json();
        if (json.messages) {
          setError(json.messages.join("; "));
        } else {
          setError(defaultError);
        }
      } else {
        setError(defaultError);
      }
    } finally {
      setInProgress(false);
    }
  };
  return (
    <div className="login-form-wrapper">
      <h3 className="login-form-heading">Sign Up</h3>
      <form className="login-form" onSubmit={signup}>
        <div className="field-wrapper">
          <label className="form-label">
            <span className="form-label-inner">Email</span>
            <input
              type="text"
              placeholder="email"
              name="email"
              className="form-input"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </label>
        </div>
        <div className="field-wrapper">
          <label className="form-label">
            <span className="form-label-inner">Password</span>
            <input
              type="password"
              placeholder="password"
              name="password"
              className="form-input"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </label>
        </div>
        <button type="submit" className="form-button">
          Sign Up
        </button>
      </form>
      <Error error={error} />
    </div>
  );
};

const LoginForm = ({ onSuccess }: LoginSignupParams) => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [inProgress, setInProgress] = useState(false);
  const [error, setError] = useState("");
  const disabled = !(email && password && !inProgress);
  const login = async (e) => {
    e.preventDefault();
    if (disabled) {
      return;
    }
    try {
      setInProgress(true);
      await api.login({ email, password });
      onSuccess?.();
    } catch (e) {
      if (e instanceof Response) {
        const json = await e.json();
        if (json.messages) {
          setError(json.messages.join("; "));
        } else {
          setError(defaultError);
        }
      } else {
        setError(defaultError);
      }
    } finally {
      setInProgress(false);
    }
  };
  return (
    <div className="login-form-wrapper">
      <h3 className="login-form-heading">Login</h3>
      <form className="login-form" onSubmit={login}>
        <div className="field-wrapper">
          <label className="form-label">
            <span className="form-label-inner">Email</span>
            <input
              type="text"
              placeholder="email"
              name="email"
              className="form-input"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </label>
        </div>
        <div className="field-wrapper">
          <label className="form-label">
            <span className="form-label-inner">Password</span>
            <input
              type="password"
              placeholder="password"
              name="password"
              className="form-input"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </label>
        </div>
        <button type="submit" className="form-button">
          Login
        </button>
      </form>
      <Error error={error} />
    </div>
  );
};

const LoginSignupForm = ({ onSuccess }: LoginSignupParams) => {
  const [mode, setMode] = useState<"login" | "signup">("login");
  const renderForm = () => {
    return mode === "login" ? (
      <LoginForm onSuccess={onSuccess} />
    ) : (
      <SignupForm onSuccess={onSuccess} />
    );
  };
  return (
    <div className="login-signup">
      {renderForm()}
      <div className="login-signup-form-switcher">
        {mode === "signup" && (
          <div className="login-signup-switcher action">
            Already have an account?{" "}
            <span
              className="login-signup-switch-action"
              onClick={() => setMode("login")}
            >
              Login
            </span>
          </div>
        )}
        {mode === "login" && (
          <div className="login-signup-switcher action">
            Do not have an account?{" "}
            <span
              className="login-signup-switch-action"
              onClick={() => setMode("signup")}
            >
              Sign Up
            </span>
          </div>
        )}
      </div>
    </div>
  );
};

export const Main: RouteHandler = (() => {
  const handler: any = () => {
    window["api"] = api;
    const [authenticated, setAuthenticated] = useState(isAuthenticated);
    const logout = async (e) => {
      e.preventDefault();
      await api.logout();
      setAuthenticated(false);
    };
    return (
      <div className="main">
        {authenticated && (
          <>
            <div className="auth-controls">
              <div className="left-controls" />
              <div className="right-controls">
                <div className="controls-action">
                  <a href="#" onClick={logout} className="controls-action-item">
                    Logout
                  </a>
                </div>
              </div>
            </div>
            <div className="auth-wrapper">
              <UrlsTab onAuthError={() => setAuthenticated(false)} />
            </div>
          </>
        )}
        {!authenticated && (
          <div className="unauth-wrapper">
            <UrlCreationBar />
            <h2 className="main-heading">Or login to your account</h2>
            <LoginSignupForm onSuccess={() => setAuthenticated(true)} />
          </div>
        )}
      </div>
    );
  };
  handler.route = "/";
  handler.exactRoute = true;
  handler.public = true;
  return handler;
})();
