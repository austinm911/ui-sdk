"use strong"
import type { ListData } from "@ui-sdk/core/select"
import {
  Select,
  SelectArrow,
  SelectClear,
  SelectContent,
  SelectEmpty,
  SelectGroup,
  SelectGroupLabel,
  SelectInput,
  SelectItem,
  SelectItemIndicator,
  SelectItemText,
  SelectLabel,
  SelectList,
  SelectSelectAll,
  SelectSeparator,
  SelectTrigger,
  SelectValue,
} from "@ui-sdk/octane/select"
import * as React from "octane"
import { createRoot } from "octane"
import * as classes from "./classes"
import { kitchenSink, show, type Env } from "./shell"
import {
  countryOptions,
  defaultValueOf,
  valuePlaceholder,
  listOf,
  recentItems,
  sampleValue,
  type Variant,
} from "./variants"

type Entry = ListData<any>[number]

// Separators have nothing that names them, so each keeps the id it first got.
const separatorIds = new WeakMap<object, number>()
const separatorCount = { last: 0 }

// Items are keyed by label, since values may be objects.
function entryKey(entry: Exclude<Entry, string>) {
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
  return `item-${(entry as { label: string }).label}`
}

// SelectItem, SelectGroup and SelectSeparator parts for a list: the variant's own, or what a data
// select shows.
function Items({ list, variant }: { list: ListData<any>; variant: Variant }) @{
  const rows = list.flatMap((entry) =>
    typeof entry === "string" ? [] : [{ entry, key: entryKey(entry) }]
  )
  @for (const row of rows; key row.key) {
    <ItemEntry entry={row.entry} variant={variant} />
  }
}

function ItemEntry({
  entry,
  variant,
}: {
  entry: Exclude<Entry, string>
  variant: Variant
}) {
  if ("type" in entry && entry.type === "separator") {
    return <SelectSeparator className={classes.separator} />
  }
  if ("type" in entry && entry.type === "group") {
    return (
      <SelectGroup>
        <SelectGroupLabel className={classes.groupLabel}>
          {entry.label}
        </SelectGroupLabel>
        @if (variant.selectAll) {
          <SelectSelectAll className={classes.selectAll}>
            {`All ${entry.label}`}
          </SelectSelectAll>
        }
        <Items list={entry.items} variant={variant} />
      </SelectGroup>
    )
  }
  const item = entry as { value: unknown; label: string; disabled?: boolean }
  return (
    <SelectItem
      className={classes.item}
      value={item.value}
      disabled={item.disabled}
    >
      <SelectItemIndicator
        className={classes.indicator}
        keepMounted={variant.indicatorKeepMounted}
      >
        {"✓"}
      </SelectItemIndicator>
      <SelectItemText className="[&_mark]:bg-transparent [&_mark]:font-semibold [&_mark]:underline">
        {item.label}
      </SelectItemText>
    </SelectItem>
  )
}

// Variants mix value types and single or multiple selection. Prettier's tsrx
// parser can't read type arguments on a JSX tag, so this instantiation names them.
const AnySelect = Select<any, boolean>

function VariantSelect({ variant, env }: { variant: Variant; env: Env }) {
  const initial =
    defaultValueOf(variant) ?? (variant.options?.multiple ? [] : null)
  const [value, setValue] = React.useState<unknown>(initial)
  const [open, setOpen] = React.useState(false)
  const data = variant.mode === "data"
  const list = listOf(variant)
  const { defaultValue, ...options } = variant.options ?? {}
  const selectAll = variant.selectAll && variant.list !== "grouped"
  return (
    <>
      <AnySelect
        {...options}
        {...(variant.list === "countries" && countryOptions)}
        {...(variant.controlled === "value"
          ? { value }
          : { defaultValue: defaultValueOf(variant) })}
        {...(variant.controlled === "open" && { open })}
        items={data ? list : undefined}
        emptyItems={variant.recent ? recentItems : undefined}
        controller={env.controller}
        container={env.container}
        onValueChange={(next, details) => {
          if (variant.controlled === "value") {
            setValue(next)
          }
          env.log(`valueChange ${show(next)} (${details.reason})`)
        }}
        onOpenChange={(next, details) => {
          if (variant.controlled === "open") {
            setOpen(next)
          }
          env.log(`openChange ${next} (${details.reason})`)
        }}
        onOpenChangeComplete={(next) => env.log(`openChangeComplete ${next}`)}
        onHighlight={(next, details) =>
          env.log(`highlight ${show(next)} #${details.index}`)
        }
      >
        <SelectLabel className={classes.label}>{variant.title}</SelectLabel>
        <SelectTrigger
          className={classes.trigger}
          disabled={variant.triggerDisabled}
        >
          <SelectValue
            className={classes.value}
            placeholder={valuePlaceholder(variant)}
            maxLabels={variant.max}
          />
          <span className={classes.chevron} aria-hidden="true">
            {"▾"}
          </span>
        </SelectTrigger>
        @if (variant.clear) {
          <SelectClear
            className={classes.clear}
            keepMounted={variant.clear === "keep-mounted"}
          >
            {"Clear"}
          </SelectClear>
        }
        @if (variant.search) {
          <SelectContent
            className={classes.content(variant.animation)}
            {...variant.content}
            anchor={env.anchor}
          >
            <SelectInput
              className={classes.search}
              aria-label="Search"
              placeholder="Search…"
            />
            <SelectEmpty className={classes.empty}>
              {"Nothing found"}
            </SelectEmpty>
            @if (data) {
              <SelectList>
                {(state: { items: unknown }) => (
                  <Items
                    list={state.items as ListData<any>}
                    variant={variant}
                  />
                )}
              </SelectList>
            } @else {
              <SelectList>
                @if (selectAll) {
                  <SelectSelectAll className={classes.selectAll}>
                    {"Select all"}
                  </SelectSelectAll>
                }
                <Items list={list} variant={variant} />
              </SelectList>
            }
          </SelectContent>
        } @else if (data) {
          <SelectContent
            className={classes.content(variant.animation, variant.arrow)}
            {...variant.content}
            anchor={env.anchor}
          >
            {(state: { items: unknown }) => (
              <Items list={state.items as ListData<any>} variant={variant} />
            )}
          </SelectContent>
        } @else {
          <SelectContent
            className={classes.content(variant.animation, variant.arrow)}
            {...variant.content}
            anchor={env.anchor}
          >
            @if (variant.arrow) {
              <SelectArrow className={classes.arrow} />
            }
            @if (selectAll) {
              <SelectSelectAll className={classes.selectAll}>
                {"Select all"}
              </SelectSelectAll>
            }
            <Items list={list} variant={variant} />
          </SelectContent>
        }
      </AnySelect>
      @if (variant.controlled === "value") {
        <>
          <span className="text-xs text-neutral-600">
            {`value: ${show(value)}`}
          </span>
          <button
            type="button"
            className={classes.button}
            onClick={() => setValue(sampleValue(variant))}
          >
            {"Set"}
          </button>
          <button
            type="button"
            className={classes.button}
            onClick={() => setValue(null)}
          >
            {"Null"}
          </button>
        </>
      }
      @if (variant.controlled === "open") {
        <label className="flex items-center gap-1.5 text-xs text-neutral-600">
          <input
            type="checkbox"
            checked={open}
            onChange={() => setOpen((was) => !was)}
          />
          {"open"}
        </label>
      }
    </>
  )
}

function mount(root: HTMLElement) {
  // The shell names only the frameworks it links between, so it's told React.
  kitchenSink(root, "octane", (slot, variant, env) =>
    // Every card is its own root, so each gets its own id prefix.
    createRoot(slot, { identifierPrefix: `${variant.id}-` }).render(
      <VariantSelect variant={variant} env={env} />
    )
  )
}

export { mount }
