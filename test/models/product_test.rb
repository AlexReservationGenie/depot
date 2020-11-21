require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  def new_product(title, description, image_url, price)
    Product.new(title: title,
                description: description,
                image_url: image_url,
                price: price)
  end

  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "product price must be positive" do
    product = new_product("title", "desc", "gif.gif", -1)
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"],
      product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal ["must be greater than or equal to 0.01"],
      product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  test "image_url" do
    ok = %w{fred.gif fred.jpg fred.png fred.JPG fred.Jpg}
    bad = %w{fred.doc fred.gif/more fred.asdf}

    ok.each do |name|
      assert new_product("title", "description", name, 1).valid?, "#{name} shouldn't be invalid"
    end

    bad.each do |name|
      assert new_product("title", "description", name, 1).invalid?, "#{name} shouldn't be valid"
    end
  end

  test "product is not valid without a unique title" do
    product = new_product(products(:one).title, "desc", "test.gif", 1)
    assert product.invalid?
    assert_equal [I18n.translate('errors.messages.taken')], product.errors[:title]
  end
end
