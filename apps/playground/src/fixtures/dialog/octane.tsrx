"use strong"
import {
  AlertDialog,
  AlertDialogBackdrop,
  AlertDialogClose,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogTitle,
  AlertDialogTrigger,
  createConfirm,
} from "@ui-sdk/octane/alert-dialog"
import {
  createDialogController,
  Dialog,
  DialogBackdrop,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogShortcut,
  DialogTitle,
  DialogTrigger,
} from "@ui-sdk/octane/dialog"
import * as React from "octane"
import { createRoot } from "octane"
import {
  alertDialogFixture,
  alertDialogOptions,
  dialogContentOptions,
  dialogFixture,
  dialogOptions,
  dialogParts,
} from "tests/fixtures/dialog.ts"
import { exposeDialogFixture, recordOpenChange } from "./shared"

const controller = createDialogController()
const confirm = createConfirm()
exposeDialogFixture(controller, confirm)

const parts = dialogParts()

function Fixture() {
  const [action, setAction] = React.useState("")
  const [triggerShown, setTriggerShown] = React.useState(true)
  // The page's options, read once, as the page's URL never changes.
  const options = React.useInitialValue(dialogOptions)
  const contentOptions = React.useInitialValue(dialogContentOptions)
  const alertOptions = React.useInitialValue(alertDialogOptions)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <Dialog
        controller={controller}
        {...options}
        onOpenChange={(open, details) => {
          recordOpenChange("dialog", open, details)
          if (!open && details.returnValue) {
            setAction(details.returnValue)
          }
        }}
      >
        @if (triggerShown) {
          <DialogTrigger>{dialogFixture.trigger}</DialogTrigger>
        }
        @if (parts.backdrop) {
          <DialogBackdrop className="dialog-backdrop" />
        }
        <DialogContent className="dialog" {...contentOptions}>
          @if (parts.title) {
            <DialogTitle className="title">{dialogFixture.title}</DialogTitle>
          }
          <DialogDescription className="description">
            {dialogFixture.description}
          </DialogDescription>
          <label className="field">
            {dialogFixture.field}
            <input defaultValue={dialogFixture.defaultValue} />
          </label>
          @if (parts.long) {
            <p className="long">{dialogFixture.long}</p>
          }
          <div className="actions">
            <button onClick={() => setAction("save")}>
              {dialogFixture.action}
            </button>
            <DialogClose>{dialogFixture.close}</DialogClose>
            @if (parts.removable) {
              <button onClick={() => setTriggerShown(false)}>
                {dialogFixture.remove}
              </button>
            }
          </div>
          @if (parts.form) {
            <form method="dialog">
              <button value={dialogFixture.form.value}>
                {dialogFixture.form.label}
              </button>
            </form>
          }
          @if (parts.nested) {
            <Dialog
              defaultOpen={parts.nestedOpen}
              onOpenChange={(open, details) =>
                recordOpenChange("nested", open, details)
              }
            >
              <DialogTrigger>{dialogFixture.nested.trigger}</DialogTrigger>
              @if (parts.backdrop) {
                <DialogBackdrop className="dialog-backdrop" />
              }
              <DialogContent className="dialog">
                <DialogTitle className="title">
                  {dialogFixture.nested.title}
                </DialogTitle>
                <DialogClose>{dialogFixture.nested.close}</DialogClose>
              </DialogContent>
            </Dialog>
          }
        </DialogContent>
      </Dialog>
      <AlertDialog controller={confirm.controller} {...alertOptions}>
        <AlertDialogTrigger>{alertDialogFixture.trigger}</AlertDialogTrigger>
        @if (parts.backdrop) {
          <AlertDialogBackdrop className="dialog-backdrop" />
        }
        <AlertDialogContent className="dialog">
          <AlertDialogTitle className="title">
            {alertDialogFixture.title}
          </AlertDialogTitle>
          <AlertDialogDescription className="description">
            {alertDialogFixture.description}
          </AlertDialogDescription>
          <div className="actions">
            <AlertDialogClose>{alertDialogFixture.cancel}</AlertDialogClose>
            <AlertDialogClose
              value="confirm"
              onClick={() => setAction("delete")}
            >
              {alertDialogFixture.action}
            </AlertDialogClose>
          </div>
        </AlertDialogContent>
      </AlertDialog>
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      <button onClick={() => controller.open()}>
        {"Open with controller"}
      </button>
      @if (parts.shortcut) {
        <DialogTrigger
          controller={controller}
          shortcut={dialogFixture.shortcut.keys}
        >
          {`${dialogFixture.shortcut.trigger} `}
          <DialogShortcut />
        </DialogTrigger>
      }
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
