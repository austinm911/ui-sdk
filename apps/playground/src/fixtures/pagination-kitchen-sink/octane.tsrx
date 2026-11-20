"use strong"
import {
  createPaginationController,
  Pagination,
  PaginationEllipsis,
  PaginationFirst,
  PaginationItem,
  PaginationLast,
  PaginationLink,
  PaginationList,
  PaginationNext,
  PaginationPrevious,
  type PaginationState,
} from "@ui-sdk/octane/pagination"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import { kitchenSink, type Env } from "./shell"
import type { Variant } from "./variants"

function VariantPagination({ variant, env }: { variant: Variant; env: Env }) {
  const [page, setPage] = React.useState(1)
  const controller = React.useInitialValue(() =>
    variant.controller ? createPaginationController() : undefined
  )
  React.useEffect(() => {
    if (!controller) {
      return
    }
    env.controls([
      ["next()", () => controller.next()],
      ["previous()", () => controller.previous()],
      ["first()", () => controller.first()],
      ["last()", () => controller.last()],
      ["setPage(5)", () => controller.setPage(5)],
      ["getPage()", () => controller.getPage()],
      ["getPageCount()", () => controller.getPageCount()],
    ])
  })
  const text = variant.steps === "text"
  return (
    <Pagination
      aria-label={variant.title}
      {...variant.options}
      {...(variant.controlled && { page })}
      getHref={
        variant.links
          ? (target) => `#kitchen-${variant.id}-${target}`
          : undefined
      }
      controller={controller}
      onPageChange={(next, details) => {
        if (variant.cancel) {
          return details.cancel()
        }
        if (variant.controlled) {
          setPage(next)
        }
        env.log(`pageChange ${next} (${details.reason}, ${details.source})`)
      }}
    >
      <PaginationList className={classes.list}>
        {({ items }: PaginationState) => (
          <>
            @if (!text) {
              <PaginationItem>
                <PaginationFirst
                  className={classes.step}
                  aria-label="First page"
                >
                  {"«"}
                </PaginationFirst>
              </PaginationItem>
            }
            <PaginationItem>
              <PaginationPrevious
                className={classes.step}
                aria-label={text ? undefined : "Previous page"}
              >
                {text ? "‹ Previous" : "‹"}
              </PaginationPrevious>
            </PaginationItem>
            @for (const item of items; key item) {
              <PaginationItem>
                @if (typeof item === "number") {
                  <PaginationLink className={classes.link} page={item} />
                } @else {
                  <PaginationEllipsis className={classes.ellipsis} />
                }
              </PaginationItem>
            }
            <PaginationItem>
              <PaginationNext
                className={classes.step}
                aria-label={text ? undefined : "Next page"}
              >
                {text ? "Next ›" : "›"}
              </PaginationNext>
            </PaginationItem>
            @if (!text) {
              <PaginationItem>
                <PaginationLast className={classes.step} aria-label="Last page">
                  {"»"}
                </PaginationLast>
              </PaginationItem>
            }
          </>
        )}
      </PaginationList>
    </Pagination>
  )
}

function mount(root: HTMLElement) {
  // The shell names only the frameworks it links to, so this page shows as React's.
  kitchenSink(root, "octane", (slot, variant, env) =>
    createRoot(slot).render(<VariantPagination variant={variant} env={env} />)
  )
}

export { mount }
