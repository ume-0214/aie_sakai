#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'kconv'
require 'csv'

# ソートしてCSVファイルに書き込み
def write_csv(row, column, path)
  elements = {}

  for i in 0..(row.length - 1)
    line = row[i]
    key = line[2]

    if elements.key?(key)
      elements[key] << line
    else
      elements.store(key, [line])
    end
  end

  sort_elements = elements.keys.sort.reverse

  CSV.open(path, 'w') do |writer|
    writer << column

    sort_elements.each do |key|
      lines = elements[key]
      
      lines.each do |line|
        writer << line
      end
    end
  end

end

# 手掛かり表現から獲得される共通頻出表現の状態を書き込む
def write_common_status(num, init, t_a, seeds, commonsManager, column = [], row = [])
  threshold = t_a.to_f * ((Math.log10(seeds.length) / (Math.log10(2))))
  t = t_a.gsub(".", "")
  path = "/home/ume/workspace/kakaku_result/Camera/examination_result/" + num.to_s + "/sort_common_" + init + "_" + t + ".csv"

  column[0..2] = "", threshold.to_s, "H"

  seeds.each do |seed|
    column << seed.name
  end

  commonsManager.each_common do |common|
    line = Array.new(column.length, 0)

    if common.entropy > threshold
      line[0..2] = common.name, "○", common.entropy
    else
      line[0..2] = common.name, "×", common.entropy
    end

    common.each_seed do |seed|
      index = column.index(seed)
      line[index] = common.get_seed_count(seed)
    end

    row << line
  end

  write_csv(row, column, path)

end

# 共通頻出表現から獲得される手掛かり表現の状態を書き込む
def write_seed_status(num, init, t_a, commons, seedsManager, column = [], row = [])
  threshold = t_a.to_f * ((Math.log10(commons.length) / (Math.log10(2))))
  t = t_a.gsub(".", "")
  path = "/home/ume/workspace/kakaku_result/Camera/examination_result/" + num.to_s + "/sort_seed_" + init + "_" + t + ".csv"

  column[0..2] = "", threshold.to_s, "H"

  commons.each do |common|
    column << common.name
  end

  seedsManager.each_seed do |seed|
    line = Array.new(column.length, 0)

    if seed.entropy > threshold
      line[0..2] = seed.name, "○", seed.entropy
    else
      line[0..2] = seed.name, "×", seed.entropy
    end

    seed.each_common do |common|
      index = column.index(common)
      line[index] = seed.get_common_count(common)
    end

    row << line
  end

  write_csv(row, column, path)

end
