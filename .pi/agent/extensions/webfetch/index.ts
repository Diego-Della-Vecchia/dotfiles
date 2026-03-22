import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import TurndownService from "turndown";

const MAX_RESPONSE_SIZE = 5 * 1024 * 1024; // 5MB
const DEFAULT_TIMEOUT = 30 * 1000; // 30 seconds
const MAX_TIMEOUT = 120 * 1000; // 2 minutes

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "webfetch",
    label: "Web Fetch",
    description: `Fetches content from a specified URL and returns it in the requested format (markdown, text, or HTML).

Usage notes:
- The URL must be a fully-formed valid URL starting with http:// or https://
- Format options: "markdown" (default), "text", or "html"
- This tool is read-only and does not modify any files
- Results may be truncated if the content is very large (5MB limit)`,
    promptSnippet: "Fetch content from a URL and convert to markdown, text, or HTML",
    promptGuidelines: [
      "Use when you need to retrieve and analyze web content",
      "Use markdown format for most web pages to get clean, readable content",
      "Use html format when you need the raw HTML source",
      "Use text format when you only need the plain text content without formatting",
      "For images, the tool will return the image as a base64 data URL",
    ],

    parameters: Type.Object({
      url: Type.String({
        description: "The URL to fetch content from (must start with http:// or https://)",
      }),
      format: Type.Optional(
        Type.Union([Type.Literal("markdown"), Type.Literal("text"), Type.Literal("html")], {
          description: "The format to return the content in (markdown, text, or html). Defaults to markdown.",
          default: "markdown",
        })
      ),
      timeout: Type.Optional(
        Type.Number({
          description: "Optional timeout in seconds (max 120)",
        })
      ),
    }),

    async execute(toolCallId, params, signal, onUpdate, ctx) {
      // Validate URL
      if (!params.url.startsWith("http://") && !params.url.startsWith("https://")) {
        return {
          content: [{ type: "text", text: "Error: URL must start with http:// or https://" }],
          isError: true,
        };
      }

      onUpdate?.({ content: [{ type: "text", text: `Fetching ${params.url}...` }] });

      const timeout = Math.min((params.timeout ?? DEFAULT_TIMEOUT / 1000) * 1000, MAX_TIMEOUT);

      // Create abort controller with timeout
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);

      // Combine with external signal if provided
      if (signal) {
        signal.addEventListener("abort", () => controller.abort());
      }

      try {
        // Build Accept header based on requested format with q parameters for fallbacks
        let acceptHeader = "*/*";
        const format = params.format ?? "markdown";
        switch (format) {
          case "markdown":
            acceptHeader = "text/markdown;q=1.0, text/x-markdown;q=0.9, text/plain;q=0.8, text/html;q=0.7, */*;q=0.1";
            break;
          case "text":
            acceptHeader = "text/plain;q=1.0, text/markdown;q=0.9, text/html;q=0.8, */*;q=0.1";
            break;
          case "html":
            acceptHeader = "text/html;q=1.0, application/xhtml+xml;q=0.9, text/plain;q=0.8, text/markdown;q=0.7, */*;q=0.1";
            break;
          default:
            acceptHeader =
              "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8";
        }

        const headers = {
          "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36",
          Accept: acceptHeader,
          "Accept-Language": "en-US,en;q=0.9",
        };

        const initial = await fetch(params.url, { signal: controller.signal, headers });

        // Retry with honest UA if blocked by Cloudflare bot detection (TLS fingerprint mismatch)
        const response =
          initial.status === 403 && initial.headers.get("cf-mitigated") === "challenge"
            ? await fetch(params.url, { signal: controller.signal, headers: { ...headers, "User-Agent": "pi-coding-agent" } })
            : initial;

        clearTimeout(timeoutId);

        if (!response.ok) {
          return {
            content: [{ type: "text", text: `Error: Request failed with status code: ${response.status}` }],
            isError: true,
          };
        }

        // Check content length
        const contentLength = response.headers.get("content-length");
        if (contentLength && parseInt(contentLength) > MAX_RESPONSE_SIZE) {
          return {
            content: [{ type: "text", text: "Error: Response too large (exceeds 5MB limit)" }],
            isError: true,
          };
        }

        const arrayBuffer = await response.arrayBuffer();
        if (arrayBuffer.byteLength > MAX_RESPONSE_SIZE) {
          return {
            content: [{ type: "text", text: "Error: Response too large (exceeds 5MB limit)" }],
            isError: true,
          };
        }

        const contentType = response.headers.get("content-type") || "";
        const mime = contentType.split(";")[0]?.trim().toLowerCase() || "";

        // Check if response is an image
        const isImage = mime.startsWith("image/") && mime !== "image/svg+xml" && mime !== "image/vnd.fastbidsheet";

        if (isImage) {
          const base64Content = Buffer.from(arrayBuffer).toString("base64");
          return {
            content: [
              { type: "text", text: `Fetched image from ${params.url}` },
              { type: "image_url", image_url: { url: `data:${mime};base64,${base64Content}` } },
            ],
            details: { url: params.url, mime, size: arrayBuffer.byteLength },
          };
        }

        const content = new TextDecoder().decode(arrayBuffer);

        // Handle content based on requested format and actual content type
        switch (format) {
          case "markdown":
            if (contentType.includes("text/html")) {
              const markdown = convertHTMLToMarkdown(content);
              return {
                content: [{ type: "text", text: markdown }],
                details: { url: params.url, format: "markdown", contentType },
              };
            }
            return {
              content: [{ type: "text", text: content }],
              details: { url: params.url, format: "markdown", contentType },
            };

          case "text":
            if (contentType.includes("text/html")) {
              const text = extractTextFromHTML(content);
              return {
                content: [{ type: "text", text }],
                details: { url: params.url, format: "text", contentType },
              };
            }
            return {
              content: [{ type: "text", text: content }],
              details: { url: params.url, format: "text", contentType },
            };

          case "html":
            return {
              content: [{ type: "text", text: content }],
              details: { url: params.url, format: "html", contentType },
            };

          default:
            return {
              content: [{ type: "text", text: content }],
              details: { url: params.url, format: "raw", contentType },
            };
        }
      } catch (error) {
        clearTimeout(timeoutId);
        if ((error as Error).name === "AbortError") {
          return {
            content: [{ type: "text", text: `Error: Request timed out after ${timeout}ms` }],
            isError: true,
          };
        }
        return {
          content: [{ type: "text", text: `Error: ${(error as Error).message}` }],
          isError: true,
        };
      }
    },
  });
}

function extractTextFromHTML(html: string): string {
  // Simple HTML to text extraction without external dependencies
  // Remove script and style elements
  let text = html
    .replace(/<script[^>]*>[\s\S]*?<\/script>/gi, "")
    .replace(/<style[^>]*>[\s\S]*?<\/style>/gi, "")
    .replace(/<noscript[^>]*>[\s\S]*?<\/noscript>/gi, "")
    .replace(/<iframe[^>]*>[\s\S]*?<\/iframe>/gi, "")
    .replace(/<object[^>]*>[\s\S]*?<\/object>/gi, "")
    .replace(/<embed[^>]*>[\s\S]*?<\/embed>/gi, "");

  // Replace common block elements with newlines
  text = text
    .replace(/<\/p>/gi, "\n\n")
    .replace(/<br\s*\/?>/gi, "\n")
    .replace(/<\/div>/gi, "\n")
    .replace(/<\/h[1-6]>/gi, "\n\n");

  // Remove all remaining HTML tags
  text = text.replace(/<[^>]+>/g, "");

  // Decode common HTML entities
  text = text
    .replace(/&nbsp;/g, " ")
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'");

  // Normalize whitespace
  text = text
    .replace(/\n{3,}/g, "\n\n")
    .trim();

  return text;
}

function convertHTMLToMarkdown(html: string): string {
  const turndownService = new TurndownService({
    headingStyle: "atx",
    hr: "---",
    bulletListMarker: "-",
    codeBlockStyle: "fenced",
    emDelimiter: "*",
  });
  turndownService.remove(["script", "style", "meta", "link"]);
  return turndownService.turndown(html);
}