# モジュールの役割について確認したい場合は[https://diver.diveintocode.jp/curriculums/2360]のテキストを参考にしてください。
require "kosi"
require_relative "item"

# このモジュールをインクルードすると、自身の所有するItemインスタンスを操れるようになります。
module ItemManager
  def items # 自身の所有する（自身がオーナーとなっている）全てのItemインスタンスを返します。
    Item.all.select{|item| item.owner == self }
  end

  def pick_items(number, quantity) # numberと対応した自身の所有するItemインスタンスを指定されたquantitiy分返します。
    items = stock.find{|stock| stock[:number] == number }&.dig(:items)
    return if items.nil? || items.size < quantity
    items.slice(0, quantity)
  end

  def items_list # 自身の所有するItemインスタンスの在庫状況を、["番号", "商品名", "金額", "数量"]という列でテーブル形式にして出力します。
    kosi = Kosi::Table.new({header: %w{番号 商品名 金額 数量}}) # Gemgileに"kosi"のURLを記載
    print kosi.render(
      stock.map do |stock|
        [
          stock[:number],
          stock[:label][:name],
          stock[:label][:price],
          stock[:items].size
        ]
      end
    )
  end

  private

  def stock # 自身の所有するItemインスタンスの在庫状況を返します。
    items
      .group_by{|item| item.label } # Item#labelで同じ値を返すItemインスタンスで分類します。
      .map.with_index do |label_and_items, index|
        {
          number: index,
          label: {
            name: label_and_items[0][:name],
            price: label_and_items[0][:price],
          },
          items: label_and_items[1], # このitemsの中に、分類されたItemインスタンスを格納します。
        }
      end
  end

end
