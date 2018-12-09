#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'kconv'
require 'csv'

# 出力結果の読み込みを行なうクラス
class ResultReader

  def initialize(seed_path, common_path, seeds = [], commons = [])
    @seed_path = seed_path
    @common_path = common_path
    @seeds = seeds
    @commons = commons
  end

  # CSVの出力結果の読み込み（種表現）
  def csv_seed_read
    io = open(@seed_path)
    lines = io.readlines
    io.close

    for i in 1..(lines.length - 1)
      line = lines[i]
      ary = line.split(",")

      if ary[1].toutf8 == "○"
        @seeds << ary[0].toutf8
      else
        break
      end
    end

  end

  # CSVの出力結果の読み込み（共通頻出表現）
  def csv_common_read
    io = open(@common_path)
    lines = io.readlines
    io.close

    for i in 1..(lines.length - 1)
      line = lines[i]
      ary = line.split(",")

      if ary[1].toutf8 == "○"
        @commons << ary[0].toutf8
      else
        break
      end
    end
  end

  # 種表現の取得
  def each_seed
    @seeds.each do |s|
      yield(s)
    end
  end

  # 共通頻出表現の取得
  def each_common
    @commons.each do |c|
      yield(c)
    end
  end

end
