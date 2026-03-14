return {
  "L3MON4D3/LuaSnip",
  config = function()
    local ls = require("luasnip")
    local s = ls.snippet
    local i = ls.insert_node
    local fmt = require("luasnip.extras.fmt").fmt

    -- Enable autosnippets
    ls.config.set_config({
      enable_autosnippets = true,
    })

    -- Jump forward with Tab
    vim.keymap.set({ "i", "s" }, "<Tab>", function()
      if ls.expand_or_jumpable() then
        ls.expand_or_jump()
      end
    end, { silent = true })

    -- Jump backward with Shift-Tab
    vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
      if ls.jumpable(-1) then
        ls.jump(-1)
      end
    end, { silent = true })

    ls.add_snippets("cpp", {
      s(
        { trig = "cppcp", snippetType = "autosnippet" },
        fmt(
          [[
/**
 * Code by
 * HARSHIT K IIT BHILAI
 */
#include <bits/stdc++.h>

#define INP(vec,size) for (int i=0;i<size;i++) {{int temp;std::cin >> temp;vec.push_back(temp); }}
#define DISP(vec) for (size_t i = 0; i < vec.size(); ++i) std::cout << vec[i] << " "; std::cout << std::endl;
#define MAXP(vec)  *max_element(vec.begin(),vec.end());
#define SORT_UNIQUE(vec) (std::sort((vec).begin(), (vec).end()), (vec).erase(std::unique((vec).begin(), (vec).end()), (vec).end()))

#define FOR(i, a, b) for (int i = a; i < b; i++)
#define FORL(i,a,b) for (long long i=a;i<b;i++)

using ll = long long;
using ull = unsigned long long;
using u = unsigned;
using namespace std;
 
void sol() {{ 
    {}
    cout << endl;
}}
 
int main() {{
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    
    int t;
    cin >> t;

    while (t--) {{
        sol();
    }}

    return 0;
}}
]],
          {
            i(1, "// code"),
          }
        )
      ),
    })
  end,
}
