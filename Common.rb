#!/usr/bin/ruby
# -*- coding: utf-8 -*-

require 'kconv'
require 'Seed'

# 共通頻出表現クラス
class Common

  # 共通頻出表現	
  attr_reader :name

  # 共通頻出表現から得られた種表現
  attr_reader :seeds

  # 共通頻出表現のエントロピー
  attr_accessor :entropy

  def initialize(common, seeds = {})
    @name = common
    @seeds = seeds
  end

  # 種表現の追加
  def add_seed(seed)
    if @seeds.key?(seed)
      @seeds[seed] += 1
    elsif
      @seeds.store(seed, 1)
    end
  end

  # 種表現の取得
  def each_seed
    @seeds.each_key do |seed|
      yield seed
    end
  end

  # 与えられた種表現の個数を取得
  def get_seed_count(seed)
    return @seeds[seed]
  end

  # 共通頻出表現の総数を獲得
  def getCommonsCount(total = 0)
    @seeds.each_value do |count|
      total += count
    end

    return total
  end

  # 種表現候補の獲得
  def getSeeds(tree, seeds = [])
    segments = tree.getSegments(@name)

    segments.each do |segment|
      string = segment.cut_symbol
      particle = segment.getParticle
      common = string[0..(string.length - particle.length - 1)]

      next if @name != common

      nextSegments = tree.getNextSegments(segment)

      nextSegments.each do |nextSegment|
        other = nextSegment.cut_symbol

        next if particle == "など" || particle.empty? || other.empty? || other.length == 1

        seeds << Seed.new(particle + other, particle, other)
      end
    end

    return seeds
  end

end
