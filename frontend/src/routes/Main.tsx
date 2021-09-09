import * as React from "react";
import { RouteHandler } from "./topLevelRouteHandlers";

export const Main: RouteHandler = (() => {
  const handler: any = () => {
    return <div className="test">Test</div>
  };
  handler.route = '/';
  handler.exactRoute = true;
  handler.public = true;
  return handler;
})();
