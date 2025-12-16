import { Agent } from "@mastra/core/agent";

export const chatAgent = new Agent({
  id: "chat-agent",
  name: "Chat Agent",
  instructions: `あなたはエンターテイメント向けのフレンドリーなチャットボットです。
ユーザーと楽しく会話してください。
日本語で回答してください。
回答は簡潔で親しみやすいトーンで行ってください。`,
  model: "anthropic/claude-sonnet-4-20250514",
});
