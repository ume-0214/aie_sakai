#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'kconv'
require 'Common'

# 複数の共通頻出表現を管理するクラス
class CommonsManager

  attr_reader :selectedCommons

  def initialize(selectedCommons, dbManager)
    @commons = {}
    @selectedCommons = []
    @dbManager = dbManager

    selectedCommons.each do |c|
      @commons[c.name] = c
      @selectedCommons << c.name
    end
  end

  # 共通頻出表現と種表現の追加
  def add(common, seed)
    @commons[common.name] = common unless @commons.key?(common.name)
    @commons[common.name].add_seed(seed.name)
  end

  # 与えられた共通頻出表現のクラスの取得
  def get_common(common)
    return @commons[common]
  end

  # 与えられた共通頻出表現のエントロピーの値を取得
  def get_entropy(common)
    return @commons[common].entropy
  end

  # 共通頻出表現クラスの取得
  def each_common
    @commons.each_value do |common|
      yield common
    end
  end

  # 種表現候補の取得
  def getCandidateSeeds(common, sentence)
    c = @commons[common.name]
    tree = @dbManager.getTree(sentence)

    if tree != nil
      candidateSeeds = c.getSeeds(tree)
      return candidateSeeds
    else
      return []
    end
  end

  # 選別処理
  def select(seeds, t_a, commons = [])
    t = getThreshold(seeds.length, t_a)

    @commons.each do |key, common|
      h = 0.0
      n = common.getCommonsCount

      # 共通頻出表現のエントロピーの計算と選別
      common.seeds.each_value do |count|
        probability = count.to_f / n.to_f
        h += probability * ((Math.log10(probability)) / (Math.log10(2)))
      end

      h = -1 * h

      if t < h
        unless @selectedCommons.include?(key)
          commons << common
          @selectedCommons << key
        end
      end

      @commons[key].entropy = h

    end

    return commons
  end

private

  # 閾値の設定
  def getThreshold(ns, t_a)
    t = t_a.to_f * ((Math.log10(ns)) / (Math.log10(2)))

    return t
  end

end
