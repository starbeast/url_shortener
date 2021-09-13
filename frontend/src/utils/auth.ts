export const isAuthenticated = () => {
  let authenticated: boolean;
  try {
    authenticated = localStorage.getItem("authenticated") === "t";
  } catch {
    authenticated = false;
  }
  return authenticated;
};

export const markAuthenticated = (authenticated: boolean) => {
  try {
    localStorage.setItem("authenticated", authenticated ? "t" : "f");
  } catch {}
};
