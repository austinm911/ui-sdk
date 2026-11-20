"use strong"
import {
  NavigationMenu,
  NavigationMenuContent,
  NavigationMenuIndicator,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  NavigationMenuTrigger,
  NavigationMenuViewport,
} from "@ui-sdk/octane/navigation-menu"
import * as React from "octane"
import { createRoot } from "octane"
import {
  navigationMenuAction,
  navigationMenuFixture as fixture,
  navigationMenuLayout,
  navigationMenuOptions,
} from "tests/fixtures/navigation-menu.ts"

// The first item's content is wide, and the second holds the nested menu.
const items = fixture.items.map((item, index) => ({
  item,
  wide: index === 0,
  holdsNested: index === 1,
}))

function Nested() {
  const nested = fixture.nested
  return (
    <NavigationMenu orientation="vertical">
      <NavigationMenuList className="nav-list vertical">
        <NavigationMenuItem value={nested.value}>
          <NavigationMenuTrigger className="nav-trigger">
            {nested.trigger}
          </NavigationMenuTrigger>
          <NavigationMenuContent className="nav-content narrow">
            <ul>
              @for (const link of nested.links; key link.href) {
                <li>
                  <NavigationMenuLink href={link.href}>
                    {link.label}
                  </NavigationMenuLink>
                </li>
              }
            </ul>
          </NavigationMenuContent>
        </NavigationMenuItem>
      </NavigationMenuList>
    </NavigationMenu>
  )
}

function Fixture() {
  const [action, setAction] = React.useState("")
  // The page's options, read once, as the page's URL never changes.
  const options = React.useInitialValue(navigationMenuOptions)
  const layout = React.useInitialValue(navigationMenuLayout)
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <NavigationMenu
        {...options}
        aria-label={fixture.label}
        className="nav-menu"
        onValueChange={(value, { reason }) =>
          setAction(navigationMenuAction(value, reason))
        }
      >
        <NavigationMenuList
          className={
            options.orientation === "vertical"
              ? "nav-list vertical"
              : "nav-list"
          }
        >
          @for (const row of items; key row.item.value) {
            <NavigationMenuItem value={row.item.value}>
              <NavigationMenuTrigger className="nav-trigger">
                {row.item.trigger}
              </NavigationMenuTrigger>
              <NavigationMenuContent
                className={row.wide ? "nav-content" : "nav-content narrow"}
                keepMounted={layout.keepMounted}
                hiddenUntilFound={layout.hiddenUntilFound}
                {...layout.placement}
              >
                <ul>
                  @for (const link of row.item.links; key link.href) {
                    <li>
                      <NavigationMenuLink href={link.href}>
                        {link.label}
                      </NavigationMenuLink>
                    </li>
                  }
                </ul>
                @if (row.holdsNested && layout.nested) {
                  <Nested />
                }
              </NavigationMenuContent>
            </NavigationMenuItem>
          }
          <NavigationMenuItem>
            <NavigationMenuLink
              className="nav-link"
              href={fixture.link.href}
              current
            >
              {fixture.link.label}
            </NavigationMenuLink>
          </NavigationMenuItem>
        </NavigationMenuList>
        <NavigationMenuIndicator className="nav-indicator" />
        @if (layout.viewport) {
          <NavigationMenuViewport
            className="nav-viewport"
            {...layout.placement}
          />
        }
      </NavigationMenu>
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
