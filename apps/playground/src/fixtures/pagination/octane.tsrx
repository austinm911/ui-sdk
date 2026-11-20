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
import {
  paginationAction,
  paginationFixture,
  paginationOptions,
} from "tests/fixtures/pagination.ts"

const pages = createPaginationController()

function Fixture() {
  const { controlled, cancel, rekey, defaultPage, ...options } =
    React.useInitialValue(paginationOptions)
  const [action, setAction] = React.useState("")
  const [page, setPage] = React.useState(defaultPage ?? 1)
  const f = paginationFixture
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Pagination
        aria-label={f.label}
        className="pagination"
        controller={pages}
        {...options}
        {...(controlled ? { page } : { defaultPage })}
        onPageChange={(next, details) => {
          if (next === cancel) {
            return details.cancel()
          }
          setPage(next)
          setAction(paginationAction(next, details.reason))
        }}
      >
        <PaginationList
          className="pagination-list"
          key={rekey ? page : undefined}
        >
          {({ items }: PaginationState) => (
            <>
              <PaginationItem>
                <PaginationFirst
                  className="pagination-step"
                  aria-label={f.first}
                >
                  {"«"}
                </PaginationFirst>
              </PaginationItem>
              <PaginationItem>
                <PaginationPrevious
                  className="pagination-step"
                  aria-label={f.previous}
                >
                  {"‹"}
                </PaginationPrevious>
              </PaginationItem>
              @for (const item of items; key item) {
                <PaginationItem>
                  @if (typeof item === "number") {
                    <PaginationLink className="pagination-link" page={item} />
                  } @else {
                    <PaginationEllipsis className="pagination-ellipsis" />
                  }
                </PaginationItem>
              }
              <PaginationItem>
                <PaginationNext className="pagination-step" aria-label={f.next}>
                  {"›"}
                </PaginationNext>
              </PaginationItem>
              <PaginationItem>
                <PaginationLast className="pagination-step" aria-label={f.last}>
                  {"»"}
                </PaginationLast>
              </PaginationItem>
            </>
          )}
        </PaginationList>
      </Pagination>
      <button onClick={() => pages.setPage(f.controller.page)}>
        {f.controller.label}
      </button>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
