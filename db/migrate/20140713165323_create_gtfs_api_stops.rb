# The MIT License (MIT)
#
# Copyright (c) 2016 Juan M. Merlos, panatrans.org
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


class CreateGtfsApiStops < ActiveRecord::Migration
  def change
    create_table :gtfs_api_stops do |t|
      t.string :io_id
      t.string :code
      t.string :name
      t.text :desc
      t.decimal :lat, precision: 10, scale: 6
      t.decimal :lon, precision: 10, scale: 6
      t.string :zone_id, null:true #=> fare rules,
      t.string :url
      t.integer :location_type, default: 0
      t.belongs_to :parent_station, null:true
      t.string :timezone, limit: 64
      t.integer :wheelchair_boarding
      t.integer :vehicle_type

      t.belongs_to :feed, null: false, index: true
      t.timestamps null: false
    end
    add_index :gtfs_api_stops, :io_id
    add_index :gtfs_api_stops, :zone_id

  end
end
