#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'kconv'
require 'Seed'

# 種表現を管理するクラス
class SeedsManager

  attr_reader :selectedSeeds

  def initialize(selectedSeeds, dbManager)
    @seeds = {}
    @selectedSeeds = []
    @dbManager = dbManager

    selectedSeeds.each do |s|
      @seeds[s.name] = s
      @selectedSeeds << s.name
    end
  end

  # 種表現と共通頻出表現の追加
  def add(seed, common)
    @seeds[seed.name] = seed unless @seeds.key?(seed.name)
    @seeds[seed.name].add_common(common.name)
  end

  # 与えられた種表現のクラスの取得
  def get_seed(seed)
    return @seeds[seed]
  end

  # 与えられた種表現のエントロピーの値を取得
  def get_entropy(seed)
    return @seeds[seed].entropy
  end

  # 種表現クラスの獲得
  def each_seed
    @seeds.each_value do |seed|
      yield seed
    end
  end

#  # 種表現から助詞を取得しセット
#  def setParticle(seed, sentence)
#	s = @seeds[seed]
#	tree = @dbManager.getTree(sentence)
#
#	return s.setParticle(tree)
#  end

#  # 文の拡張処理
#  def expand(seed, sentence)
#	s = @seeds[seed]
#	tree = @dbManager.getTree(sentence)
#
#	segments = s.expand(tree)
#
#	return segments
#  end

  # 共通頻出表元候補の獲得
  def getCandidateCommons(seed, sentence)
    s = @seeds[seed.name]
    tree = @dbManager.getTree(sentence)

    if tree != nil
      candidateCommons = s.getCommons(tree)
      return candidateCommons
    else
      return []
    end
  end

  # 選別処理
  def select(commons, t_a, seeds = [])
    t = getThreshold(commons.length, t_a)

    @seeds.each do |key, seed|
      h = 0.0
      n = seed.getSeedsCount

      # 種表現のエントロピーの計算と選別
      seed.commons.each_value do |count|
        probability = count.to_f / n.to_f
        h += probability * ((Math.log10(probability)) / (Math.log10(2)))
      end

      h = -1 * h

      if t < h
        unless @selectedSeeds.include?(key)
          seeds << seed
          @selectedSeeds << key
        end
      end

      @seeds[key].entropy = h

    end

    return seeds
  end

private

  # 閾値の設定
  def getThreshold(ne, t_a)
    t = t_a.to_f * ((Math.log10(ne)) / (Math.log10(2)))

    return t
  end

end
