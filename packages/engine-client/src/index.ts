// Local type to avoid depending on @midday/engine build during API typecheck
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type AppType = any;
import { hc } from "hono/client";

export const client = hc<AppType>(`${process.env.ENGINE_API_URL}/`, {
  headers: {
    Authorization: `Bearer ${process.env.ENGINE_API_KEY}`,
  },
});
