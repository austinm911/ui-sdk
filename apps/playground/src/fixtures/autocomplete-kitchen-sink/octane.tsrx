"use strong"
import type { AsyncOptionsStatus } from "@ui-sdk/core/async-options"
import type { ListData } from "@ui-sdk/core/autocomplete"
import { useAsyncOptions } from "@ui-sdk/octane/async-options"
import {
  Autocomplete,
  AutocompleteArrow,
  AutocompleteClear,
  AutocompleteContent,
  AutocompleteEmpty,
  AutocompleteGroup,
  AutocompleteGroupLabel,
  AutocompleteInput,
  AutocompleteItem,
  AutocompleteLabel,
  AutocompleteList,
  AutocompleteSeparator,
  AutocompleteStatus,
  AutocompleteTrigger,
  type AutocompleteContentState,
  type AutocompleteEmptyState,
  type AutocompleteStatusState,
} from "@ui-sdk/octane/autocomplete"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import { kitchenSink, type Env } from "./shell"
import { anchorOf, filterOf, listOf, search, type Variant } from "./variants"

type Remote = {
  items: ListData<string>
  status: AsyncOptionsStatus
  setQuery: (query: string) => void
}

type Entry = ListData<string>[number]

// Separators have nothing that names them, so each keeps the id it first got.
const separatorIds = new WeakMap<object, number>()
const separatorCount = { last: 0 }

function entryKey(entry: Entry) {
  if (typeof entry === "string") {
    return entry
  }
  if ("type" in entry && entry.type === "separator") {
    let id = separatorIds.get(entry)
    if (id === undefined) {
      separatorIds.set(entry, (id = ++separatorCount.last))
    }
    return `separator-${id}`
  }
  if ("type" in entry && entry.type === "group") {
    return `group-${entry.label}`
  }
  return (entry as { value: string }).value
}

// AutocompleteItem, AutocompleteGroup and AutocompleteSeparator parts for a list: the variant's own,
// or what a data autocomplete shows.
function Items({ list }: { list: ListData<string> }) @{
  const rows = list.map((entry) => ({ entry, key: entryKey(entry) }))
  @for (const row of rows; key row.key) {
    <ItemEntry entry={row.entry} />
  }
}

function ItemEntry({ entry }: { entry: Entry }) {
  if (typeof entry === "string") {
    return null
  }
  if ("type" in entry && entry.type === "separator") {
    return <AutocompleteSeparator className={classes.separator} />
  }
  if ("type" in entry && entry.type === "group") {
    return (
      <AutocompleteGroup>
        <AutocompleteGroupLabel className={classes.groupLabel}>
          {entry.label}
        </AutocompleteGroupLabel>
        <Items list={entry.items} />
      </AutocompleteGroup>
    )
  }
  const item = entry as {
    value: string
    label: string
    keywords?: string[]
    disabled?: boolean
  }
  return (
    <AutocompleteItem
      className={classes.item}
      value={item.value}
      label={item.label}
      keywords={item.keywords}
      disabled={item.disabled}
    >
      {item.label}
    </AutocompleteItem>
  )
}

function VariantAutocomplete({
  variant,
  env,
  remote,
}: {
  variant: Variant
  env: Env
  remote?: Remote
}) {
  const [value, setValue] = React.useState(
    () => variant.options?.defaultValue ?? ""
  )
  const [open, setOpen] = React.useState(false)
  const data = variant.mode === "data" || !!remote
  const list = remote ? remote.items : listOf(variant)
  const { defaultValue, filter, ...options } = variant.options ?? {}
  // Passed as the `children` prop: between tags, Octane would compile it
  // into a render block, which never gets the list's state.
  const listContent = data ? (
    (state: AutocompleteContentState) => (
      <Items list={state.items as ListData<string>} />
    )
  ) : (
    <Items list={list} />
  )
  return (
    <>
      <Autocomplete
        {...options}
        {...(variant.controlled === "value" ? { value } : { defaultValue })}
        {...(variant.controlled === "open" && { open })}
        filter={remote ? false : filterOf(variant)}
        status={remote?.status}
        items={data ? list : undefined}
        controller={env.controller}
        container={env.container}
        onValueChange={(next, details) => {
          if (variant.controlled === "value") {
            setValue(next)
          }
          remote?.setQuery(next)
          env.log(`valueChange ${JSON.stringify(next)} (${details.reason})`)
        }}
        onOpenChange={(next, details) => {
          if (variant.controlled === "open") {
            setOpen(next)
          }
          env.log(`openChange ${next} (${details.reason})`)
        }}
        onOpenChangeComplete={(next) => env.log(`openChangeComplete ${next}`)}
        onHighlight={(next, details) =>
          env.log(`highlight ${JSON.stringify(next)} #${details.index}`)
        }
        onSubmit={(next) => env.log(`onSubmit ${JSON.stringify(next)}`)}
      >
        <AutocompleteLabel className={classes.label}>
          {variant.title}
        </AutocompleteLabel>
        <AutocompleteInput
          className={classes.input}
          placeholder="Search fruits…"
        />
        @if (variant.trigger) {
          <AutocompleteTrigger
            className={classes.trigger}
            aria-label="Show fruits"
          >
            {"▾"}
          </AutocompleteTrigger>
        }
        @if (variant.clear) {
          <AutocompleteClear
            className={classes.clear}
            aria-label="Clear"
            keepMounted={variant.clear === "keep-mounted"}
          >
            {"Clear"}
          </AutocompleteClear>
        }
        <AutocompleteContent
          className={classes.content(variant.animation, variant.arrow)}
          {...variant.content}
          anchor={anchorOf(variant)}
        >
          @if (variant.arrow) {
            <AutocompleteArrow className={classes.arrow} />
          }
          @if (remote) {
            <AutocompleteStatus className={classes.status}>
              {(state: AutocompleteStatusState) =>
                state.loading
                  ? "Loading…"
                  : state.status === "error"
                    ? "Couldn't load fruits."
                    : `${state.count} results`
              }
            </AutocompleteStatus>
          }
          <AutocompleteEmpty className={classes.empty}>
            {(state: AutocompleteEmptyState) =>
              state.empty && !state.loading ? "No fruits found." : null
            }
          </AutocompleteEmpty>
          <AutocompleteList
            className={variant.arrow ? classes.scrollingList : undefined}
            children={listContent}
          />
        </AutocompleteContent>
      </Autocomplete>
      @if (variant.controlled === "value") {
        <>
          <span className="text-xs text-neutral-600">
            {`value: ${JSON.stringify(value)}`}
          </span>
          <button
            type="button"
            className={classes.button}
            onClick={() => setValue("Mango")}
          >
            {"Set “Mango”"}
          </button>
          <button
            type="button"
            className={classes.button}
            onClick={() => setValue("")}
          >
            {"Empty"}
          </button>
        </>
      }
      @if (variant.controlled === "open") {
        <label className="flex items-center gap-1.5 text-xs text-neutral-600">
          <input
            type="checkbox"
            checked={open}
            onChange={(event: Event) =>
              setOpen((event.currentTarget as HTMLInputElement).checked)
            }
          />
          {"open"}
        </label>
      }
    </>
  )
}

// Async suggestions come from a hook, so they get a component of their own.
function AsyncAutocomplete({ variant, env }: { variant: Variant; env: Env }) {
  const remote = useAsyncOptions(search(variant.async!), { immediate: true })
  return <VariantAutocomplete variant={variant} env={env} remote={remote} />
}

function VariantRoot({ variant, env }: { variant: Variant; env: Env }) @{
  @if (variant.async) {
    <AsyncAutocomplete variant={variant} env={env} />
  } @else {
    <VariantAutocomplete variant={variant} env={env} />
  }
}

function mount(root: HTMLElement) {
  kitchenSink(root, "octane", (slot, variant, env) =>
    // Every card is its own root, so each gets its own id prefix.
    createRoot(slot, { identifierPrefix: `${variant.id}-` }).render(
      <VariantRoot variant={variant} env={env} />
    )
  )
}

export { mount }
