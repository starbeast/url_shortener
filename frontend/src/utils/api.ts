import { toCamel, toSnake } from "convert-keys";
import cookies from "js-cookie";
import queryString from "query-string";
import { markAuthenticated } from "./auth";

const camelize = (value) => {
  if (value.type === "application/zip") {
    return value;
  }

  return toCamel(value);
};

const snake = (value) => {
  return toSnake(value);
};

const csrfMethods = ["PATCH", "POST", "PUT", "DELETE"];
const bodylessMethods = ["GET", "HEAD"];

type Options = {
  query?: { [key: string]: any };
  body?: { [key: string]: any };
  fetchOpts?: RequestInit;
  onError?: (e: Response | Error) => Promise<void>;
  skipCsrf?: boolean;
};

type UrlOpts = {
  url: string;
};

type ApiKeyOpts = {
  alias: string;
  expiresAt: string;
};
type SignupOpts = {
  email: string;
  password: string;
};
type LoginOpts = {
  email: string;
  password: string;
};

const apiCall = async (
  path: string,
  options: Options = { body: {}, query: {} },
) => {
  const { fetchOpts, onError, skipCsrf } = options;
  try {
    const url = `${API_URL}${path}`;
    const body = options.body || {};
    const query = options.query ? queryString.stringify(toSnake(options.query)) : "";
    const init: RequestInit = {
      ...fetchOpts,
      credentials: "include",
      ...(fetchOpts?.method ||
      bodylessMethods.find((m) => m === fetchOpts?.method)
        ? { body: JSON.stringify(snake(body)) }
        : {}),
      headers: {
        ...(fetchOpts?.headers || {}),
        "Content-Type": "application/json",
      },
    };
    if (
      !skipCsrf &&
      init.headers &&
      csrfMethods.find((m) => m === fetchOpts?.method)
    ) {
      init.headers["X-CSRF-Token"] = cookies.get(CSRF_COOKIE);
    }
    const response = await fetch(url + (query ? `?${query}` : ""), init);
    const responseJson = await response.json();
    return camelize(responseJson);
  } catch (error) {
    if (onError) {
      return onError(error);
    } else {
      throw error;
    }
  }
};

const handleNotAuthorized = async (error) => {
  if (error instanceof Response && error.status === 401) {
    markAuthenticated(false);
    return;
  }
  throw error;
};

export const fetchUrls = (page: number = 1, perPage: number = 25) =>
  apiCall("/urls", { onError: handleNotAuthorized, query: { page, perPage } });
export const fetchApiKeys = (page: number = 1, perPage: number = 25) =>
  apiCall("/api_tokens", {
    onError: handleNotAuthorized,
    query: { page, perPage },
  });
export const createUrl = (urlOpts: UrlOpts) =>
  apiCall("/urls", { fetchOpts: { method: "POST" }, body: urlOpts });
export const createApiKey = (apiKeyOpts: ApiKeyOpts) =>
  apiCall("/api_tokens", { fetchOpts: { method: "POST" }, body: apiKeyOpts });
export const destroyUrl = (shortenedUrl: string) =>
  apiCall(`/urls/${shortenedUrl}`, { fetchOpts: { method: "DELETE" } });
export const destroyApiKey = (id: number) =>
  apiCall(`/api_tokens/${id}`, { fetchOpts: { method: "DELETE" } });
export const login = (loginOpts: LoginOpts) =>
  apiCall("/login", {
    fetchOpts: { method: "POST" },
    body: loginOpts,
    skipCsrf: true,
  });
export const logout = () => apiCall("/logout");
export const signUp = (signupOpts: SignupOpts) =>
  apiCall("/signup", {
    fetchOpts: { method: "POST" },
    body: signupOpts,
    skipCsrf: true,
  });

export default {
  fetchUrls,
  fetchApiKeys,
  createUrl,
  createApiKey,
  destroyApiKey,
  destroyUrl,
  login,
  logout,
  signUp,
};
