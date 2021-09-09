import { useState } from "react";
import * as React from "react";
import { isAuthenticated } from "../utils/auth"
import { RouteHandler } from "./topLevelRouteHandlers";

type Tab = 'urls' | 'apiTokens';

export const Main: RouteHandler = (() => {
  const handler: any = () => {
    const [authenticated, setAuthenticated] = useState(isAuthenticated);
    const [selectedTab, setSelectedTab] = useState<Tab>('urls');
    const renderSelectedTab = () => {
      switch(selectedTab) {
        case 'apiTokens': return <ApiTokensTab />
        default: return <UrlsTab />
      }
    };
    return <div className="test">Test</div>
  };
  handler.route = '/';
  handler.exactRoute = true;
  handler.public = true;
  return handler;
})();
