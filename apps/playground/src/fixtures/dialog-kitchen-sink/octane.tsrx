"use strong"
import {
  AlertDialog,
  AlertDialogBackdrop,
  AlertDialogClose,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogTitle,
  AlertDialogShortcut,
  AlertDialogTrigger,
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
import * as classes from "./classes"
import { kitchenSink, type Env } from "./shell"
import { flakyAction, type Variant } from "./variants"

// The long body's lines, which name themselves.
const lines = Array.from({ length: 40 }, (_, index) => index + 1)

function Body({ variant, onDirty }: { variant: Variant; onDirty: () => void }) {
  if (variant.body === "text") {
    return null
  }
  if (variant.body === "long") {
    return (
      <>
        @for (const line of lines; key line) {
          <p>{`Line ${line}`}</p>
        }
      </>
    )
  }
  if (variant.body === "dialog-form") {
    return (
      <form method="dialog" className="mb-4 flex gap-2">
        <button className={classes.button} value="draft">
          {"Save draft"}
        </button>
        <button className={classes.button} value="publish">
          {"Publish"}
        </button>
      </form>
    )
  }
  if (variant.body === "nested") {
    return (
      <Dialog>
        <DialogTrigger className={`${classes.trigger} mb-4`}>
          {"Advanced"}
        </DialogTrigger>
        <DialogBackdrop className={classes.backdrop()} />
        <DialogContent className={classes.content()}>
          <DialogTitle className={classes.title}>
            {"Advanced settings"}
          </DialogTitle>
          <DialogClose className={classes.button}>{"Done"}</DialogClose>
        </DialogContent>
      </Dialog>
    )
  }
  return (
    <label className="mb-4 flex flex-col gap-1">
      {"Name"}
      <input className={classes.input} defaultValue="Ada" onInput={onDirty} />
    </label>
  )
}

function VariantDialog({ variant, env }: { variant: Variant; env: Env }) {
  const [open, setOpen] = React.useState(false)
  const [dirty, setDirty] = React.useState(false)
  const local = React.useInitialValue(() => createDialogController())
  const controller = env.controller ?? local
  const Root = variant.alert ? AlertDialog : Dialog
  const Trigger = variant.alert ? AlertDialogTrigger : DialogTrigger
  const Backdrop = variant.alert ? AlertDialogBackdrop : DialogBackdrop
  const Content = variant.alert ? AlertDialogContent : DialogContent
  const Title = variant.alert ? AlertDialogTitle : DialogTitle
  const Description = variant.alert ? AlertDialogDescription : DialogDescription
  const Close = variant.alert ? AlertDialogClose : DialogClose
  const Shortcut = variant.alert ? AlertDialogShortcut : DialogShortcut
  const backdrop = variant.backdrop ?? "part"
  // A changed form refuses dismissals and asks. The Close part always closes.
  return (
    <div className="flex items-center gap-3">
      <Root
        {...variant.options}
        controller={controller as never}
        container={env.container}
        {...(variant.controlled && { open })}
        {...(variant.guard && { dismissible: !dirty })}
        onDismissAttempt={(details) => {
          env.log(`dismissAttempt (${details.reason})`)
          if (variant.guard && window.confirm("Discard changes?")) {
            controller.close()
          }
        }}
        onOpenChange={(next, details) => {
          if (!next) {
            setDirty(false)
          }
          if (variant.controlled) {
            setOpen(next)
          }
          env.log(
            `openChange ${next} (${details.reason})${details.returnValue ? ` returnValue=${details.returnValue}` : ""}`
          )
        }}
        onOpenChangeComplete={(next) => env.log(`openChangeComplete ${next}`)}
      >
        <Trigger className={classes.trigger} shortcut={variant.shortcut}>
          {variant.trigger ?? "Open"}
          @if (variant.shortcut) {
            <Shortcut className="text-xs text-neutral-500" />
          }
        </Trigger>
        @if (backdrop === "part") {
          <Backdrop className={classes.backdrop(variant.animation)} />
        }
        <Content
          className={classes.content(variant.animation, backdrop === "pseudo")}
          {...variant.content}
        >
          @if (variant.titled !== false) {
            <Title className={classes.title}>{variant.title}</Title>
          }
          <Description className={classes.description}>
            {variant.note ?? "A dialog."}
          </Description>
          @if (!variant.alert) {
            <Body variant={variant} onDirty={() => setDirty(true)} />
          }
          <div className="flex justify-end gap-2">
            @if (!variant.alert) {
              <button
                className={classes.button}
                data-save=""
                onClick={() => env.log("save")}
              >
                {"Save"}
              </button>
            }
            <Close className={classes.button}>
              {variant.alert ? "Cancel" : "Close"}
            </Close>
            @if (variant.alert) {
              <Close
                className={classes.danger}
                value="confirm"
                {...(variant.action && { action: flakyAction })}
              >
                {(state: { pending: boolean; error: unknown }) =>
                  state.pending ? "Deleting…" : state.error ? "Retry" : "Delete"
                }
              </Close>
            }
          </div>
        </Content>
      </Root>
      @if (variant.controlled) {
        <label className="flex items-center gap-1.5 text-xs text-neutral-600">
          <input
            type="checkbox"
            checked={open}
            onChange={(event) => setOpen(event.currentTarget.checked)}
          />
          {"open"}
        </label>
      }
    </div>
  )
}

function mount(root: HTMLElement) {
  kitchenSink(root, "react", (slot, variant, env) =>
    createRoot(slot).render(<VariantDialog variant={variant} env={env} />)
  )
}

export { mount }
