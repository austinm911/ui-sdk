"use strong"
import type { MatchSegment } from "@ui-sdk/core/combobox"

// An item's text with the parts that matched in `<mark>`, for the list
// components' item text parts.
function markSegments(segments: MatchSegment[]) {
  return <>
    @for (const { text, match } of segments) {
      @if (match) {
        <mark>{text}</mark>
      } @else {
        <>{text}</>
      }
    }
  </>
}

// The text an item text part marks: its own string content, or else its item's label.
function textToMark(children: unknown, label: string | undefined) {
  return typeof children === "string" ? children : (label ?? "")
}

export { markSegments, textToMark }
