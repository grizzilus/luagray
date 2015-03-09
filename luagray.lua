local HLIST = node.id("hlist")
local RULE = node.id("rule")
local WHAT = node.id("whatsit")
local COL = node.subtype("pdf_colorstack")

local color_push = node.new(WHAT, COL)
local color_pop = node.new(WHAT, COL)
color_push.stack = 0
color_pop.stack = 0
color_push.command = 1
color_pop.command = 2

local function textcolor(head)
  for line in node.traverse_id(HLIST, head) do
    local glue_ratio = 0
    if line.glue_order == 0 then
        if line.glue_sign == 1 then
          glue_ratio = .5 * math.min(line.glue_set, 1)
        else
          glue_ratio = -.5 * line.glue_set
        end
    end
    color_push.data = .5 + glue_ratio .. " g"
    local rule = node.new(RULE)
    rule.width = line.width
    local p = line.list
    line.list = node.copy(color_push)
    node.flush_list(p)
    node.insert_after(line.list, line.list, rule)
    node.insert_after(line.list, node.tail(line.list), node.copy(color_pop))
  end
  return head
end

luatexbase.add_to_callback("post_linebreak_filter", textcolor, "grayness", 1)
