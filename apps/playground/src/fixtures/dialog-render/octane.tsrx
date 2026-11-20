"use strong"
import {
  Dialog,
  DialogBackdrop,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogTitle,
  DialogTrigger,
} from "@ui-sdk/octane/dialog"
import { createRoot } from "octane"

function Fixture() {
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Dialog>
        <DialogTrigger
          className={(state) => (state.open ? "is-open" : "is-closed")}
          render={(props, state) => (
            <button {...props}>
              {"Shipping "}
              <span aria-hidden="true">{state.open ? "▲" : "▼"}</span>
            </button>
          )}
        />
        <DialogBackdrop
          className="dialog-backdrop"
          render={(props) => <section {...props} />}
        />
        <DialogContent
          className={(state) =>
            `dialog ${state.open ? "is-open" : "is-closed"}`
          }
        >
          <DialogTitle render={(props) => <h3 {...props} />}>
            {"Shipping"}
          </DialogTitle>
          <DialogDescription render={(props) => <div {...props} />}>
            {"Arrives in two days."}
          </DialogDescription>
          <DialogClose render={(props) => <a href="#done" {...props} />}>
            {"Done"}
          </DialogClose>
        </DialogContent>
      </Dialog>
      <button>{"After"}</button>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
