"use strong"
import {
  createFileInputController,
  FileInput,
  FileInputDropzone,
  FileInputItem,
  FileInputItemRemove,
  FileInputList,
  FileInputTrigger,
  type FileInputItemState,
} from "@ui-sdk/octane/file-input"
import {
  Field,
  FieldDescription,
  FieldError,
  FieldLabel,
} from "@ui-sdk/octane/field"
import * as React from "octane"
import { createRoot } from "octane"
import { classes as c, renderShell } from "./shell"
import {
  announcementFor,
  describe,
  sampleFile,
  validateName,
  type Variant,
} from "./variants"

function Card({
  variant,
  log,
}: {
  variant: Variant
  log: (text: string) => void
}) {
  const controller = React.useInitialValue(createFileInputController)
  const [files, setFiles] = React.useState<File[]>([])
  const note = React.useRef<HTMLTextAreaElement>(null)
  const page = typeof variant.dropzone === "object"

  const input = (
    <FileInput
      className={c.root}
      {...variant.props}
      {...(variant.controlled && { value: files })}
      validate={variant.validate ? validateName : undefined}
      announcement={announcementFor(variant)}
      controller={variant.controller ? controller : undefined}
      onValueChange={(value, details) => {
        log(describe(details))
        setFiles(value)
      }}
      onReject={(rejected, details) => log(describe({ ...details, rejected }))}
    >
      @if (variant.dropzone) {
        <FileInputDropzone
          className={page ? c.page : c.zone}
          target={page ? "document" : undefined}
          pasteTarget={variant.pasteTarget ? () => note.current : undefined}
        >
          <span>{page ? "Drop files anywhere" : "Drop files here"}</span>
          @if (variant.trigger) {
            <FileInputTrigger className={c.button}>
              {"Choose files"}
            </FileInputTrigger>
          }
          @if (variant.nested) {
            <FileInput
              onValueChange={(_, details) => log(`inner ${describe(details)}`)}
            >
              <FileInputDropzone className={c.zone}>
                {"Inner zone"}
              </FileInputDropzone>
            </FileInput>
          }
        </FileInputDropzone>
      } @else if (variant.trigger) {
        <FileInputTrigger className={c.button}>{"Choose files"}</FileInputTrigger>
      }
      @if (variant.list) {
        <FileInputList className={c.list} aria-label="Files">
          <FileInputItem className={c.item}>
            {({ file }: FileInputItemState) => (
              <>
                {file.name}
                <FileInputItemRemove className={c.remove}>
                  {"×"}
                </FileInputItemRemove>
              </>
            )}
          </FileInputItem>
        </FileInputList>
      }
    </FileInput>
  )

  return (
    <form className={c.form}>
      @if (page) {
        <span>{"Drag files over the window."}</span>
      }
      @if (variant.field) {
        <Field>
          <FieldLabel>{"Files"}</FieldLabel>
          {input}
          <FieldDescription className={c.description}>
            {"Required."}
          </FieldDescription>
          <FieldError className={c.error} />
        </Field>
      } @else {
        <>{input}</>
      }
      @if (variant.pasteTarget) {
        <textarea ref={note} className={c.note} aria-label="Paste here" />
      }
      @if (variant.controller) {
        <div className="flex gap-2">
          <button
            type="button"
            className={c.button}
            onClick={() => controller.addFiles([sampleFile()])}
          >
            {"Add a sample file"}
          </button>
          <button
            type="button"
            className={c.button}
            onClick={() => controller.open()}
          >
            {"Open the picker"}
          </button>
          <button
            type="button"
            className={c.button}
            onClick={() => controller.clear()}
          >
            {"Clear"}
          </button>
        </div>
      }
      <div className="flex gap-2">
        <button type="submit" className={c.button}>
          {"Submit"}
        </button>
        <button type="reset" className={c.button}>
          {"Reset"}
        </button>
      </div>
    </form>
  )
}

function mount(root: HTMLElement) {
  renderShell(root, (slot, variant, log) =>
    createRoot(slot).render(<Card variant={variant} log={log} />)
  )
}

export { mount }
