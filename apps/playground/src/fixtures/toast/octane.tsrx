"use strong"
import { confirm } from "@ui-sdk/octane/alert-dialog"
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogTitle,
  DialogTrigger,
} from "@ui-sdk/octane/dialog"
import { OverlayHost } from "@ui-sdk/octane/overlays"
import {
  Toast,
  ToastAction,
  ToastClose,
  ToastDescription,
  ToastRegion,
  ToastTitle,
  type ToastData,
} from "@ui-sdk/octane/toast"
import * as React from "octane"
import { createRoot } from "octane"
import { toastFixture, toastOptions, usesHost } from "tests/fixtures/toast.ts"
import { createFixtureToasts } from "./shared"

// Reports to the Last action output, once the fixture has mounted.
const recorder = { record: (_action: string) => {} }
const toasts = createFixtureToasts<unknown>((action) => recorder.record(action))

// A hosted toast, with its cancel button when it has one.
const hostedToast = (toast: ToastData<unknown>) => (
  <Toast className="toast">
    <ToastTitle />
    <ToastDescription />
    <ToastAction />
    @if (toast.cancel) {
      <ToastClose action={toast.cancel.onCancel}>
        {toast.cancel.label}
      </ToastClose>
    }
  </Toast>
)

function Fixture() {
  const [action, setAction] = React.useState("")
  React.useLayoutEffect(() => {
    recorder.record = setAction
  })
  // The page's options, read once, as the page's URL never changes.
  const host = React.useInitialValue(usesHost)
  const options = React.useInitialValue(toastOptions)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <button onClick={toasts.basic}>{toastFixture.basic.trigger}</button>
      <button onClick={toasts.success}>{toastFixture.success.trigger}</button>
      <button onClick={toasts.error}>{toastFixture.error.trigger}</button>
      <button onClick={toasts.promise}>{toastFixture.promise.trigger}</button>
      <Dialog>
        <DialogTrigger>{toastFixture.dialog.trigger}</DialogTrigger>
        <DialogContent className="dialog">
          <DialogTitle className="title">
            {toastFixture.dialog.title}
          </DialogTitle>
          <button onClick={toasts.basic}>{toastFixture.dialog.toast}</button>
          <DialogClose>{toastFixture.dialog.close}</DialogClose>
        </DialogContent>
      </Dialog>
      @if (host) {
        <button
          onClick={async () => {
            const {
              title,
              confirm: confirmLabel,
              cancel,
            } = toastFixture.confirm
            const yes = await confirm({
              title,
              confirmLabel,
              cancelLabel: cancel,
            })
            setAction(yes ? "confirmed" : "declined")
          }}
        >
          {toastFixture.confirm.trigger}
        </button>
      }
      <button>{"After"}</button>
      <output role="status" aria-label="Last action">
        {action}
      </output>
      @if (host) {
        <OverlayHost
          toast={{
            ...options,
            className: "toast-region",
            children: hostedToast,
          }}
        />
      } @else {
        <ToastRegion
          toaster={toasts.toast}
          className="toast-region"
          {...options}
        >
          {() => (
            <Toast className="toast">
              <ToastTitle className="toast-title" />
              <ToastDescription className="toast-description" />
              <ToastAction className="toast-action" />
              <ToastClose className="toast-close">
                {toastFixture.dismiss}
              </ToastClose>
            </Toast>
          )}
        </ToastRegion>
      }
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { Fixture, mount }
