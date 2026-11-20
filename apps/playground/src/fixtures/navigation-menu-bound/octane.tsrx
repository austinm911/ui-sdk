"use strong"
import {
  NavigationMenu,
  NavigationMenuContent,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  NavigationMenuTrigger,
  NavigationMenuViewport,
} from "@ui-sdk/octane/navigation-menu"
import * as React from "octane"
import { createRoot } from "octane"
import {
  exposeNavigationMenuValue,
  navigationMenuFixture as fixture,
  navigationMenuLayout,
} from "tests/fixtures/navigation-menu.ts"

function Fixture() {
  // The page's options, read once, as the page's URL never changes.
  const layout = React.useInitialValue(navigationMenuLayout)
  const [value, setValue] = React.useState<string | null>(null)
  const [completed, setCompleted] = React.useState<boolean[]>([])
  React.useLayoutEffect(() => {
    exposeNavigationMenuValue(setValue)
  })
  return (
    <div className="fixture">
      <button>{"Before"}</button>
      <NavigationMenu
        aria-label="Main"
        className="nav-menu"
        delay={0}
        closeDelay={0}
        value={value}
        onValueChange={setValue}
        onOpenChangeComplete={(open) => setCompleted((list) => [...list, open])}
      >
        <NavigationMenuList className="nav-list">
          @for (const item of fixture.items; key item.value) {
            <NavigationMenuItem value={item.value}>
              <NavigationMenuTrigger className="nav-trigger">
                {item.trigger}
              </NavigationMenuTrigger>
              <NavigationMenuContent className="nav-content">
                <ul>
                  @for (const link of item.links; key link.href) {
                    <li>
                      <NavigationMenuLink href={link.href}>
                        {link.label}
                      </NavigationMenuLink>
                    </li>
                  }
                </ul>
              </NavigationMenuContent>
            </NavigationMenuItem>
          }
        </NavigationMenuList>
        @if (layout.viewport) {
          <NavigationMenuViewport className="nav-viewport" />
        }
      </NavigationMenu>
      <button>{"After"}</button>
      <output role="status" aria-label="Completed">
        {completed.join(",")}
      </output>
    </div>
  )
}

function mount(root: HTMLElement) {
  createRoot(root).render(<Fixture />)
}

export { mount }
