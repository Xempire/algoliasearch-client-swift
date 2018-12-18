//
//  File.swift
//  AlgoliaSearch
//
//  Created by Guy Daher on 07/12/2018.
//  Copyright © 2018 Algolia. All rights reserved.
//

import Foundation

/// For better understanding of Filters, please read the documentation linked below:
/// [Documentation](https:www.algolia.com/doc/api-reference/api-parameters/filters/)
public class FilterBuilder {

    public init() {

    }

    var groups: [AnyGroup: Set<AnyFilter>] = [:]

    // TODO: vararg?
    public func add<T>(filter: T, in group: Group<T>) {
        let anyGroup = AnyGroup(group)

        let groupFilters: Set<AnyFilter>
        if let existingGroupFilters = groups[anyGroup] {
            groupFilters = existingGroupFilters.union([AnyFilter(filter)])
        } else {
            groupFilters = [AnyFilter(filter)]
        }

        groups[anyGroup] = groupFilters
    }

    func build(_ group: AnyGroup, with filters: Set<AnyFilter>) -> String {

        let sortedFiltersExpressions = filters
            .sorted { $0.attribute.name < $1.attribute.name }
            .map { $0.expression }

        if group.isConjunctive {
            return sortedFiltersExpressions.joined(separator: " AND ")
        } else {
            let subfilter = sortedFiltersExpressions.joined(separator: " OR ")
            return filters.count > 1 ? "( \(subfilter) )" : subfilter
        }
    }

    public func build() -> String {
        return groups
            .sorted { $0.key.name < $1.key.name }
            .map { build($0.key, with: $0.value) }
            .joined(separator: " AND ")
    }

    /*
     * To represent our SQL-like syntax of filters, we use a nested array of [Filter].
     * Each nested MutableList<Filter> represents a group. If this group contains two or more elements,
     * it will be considered  as a disjunctive group (Operator OR).
     * The operator AND will be used between each nested group.
     *
     * Example:
     *
     * ((FilterA), (FilterB), (FilterC, FilterD), (FilterE, FilterF))
     *
     * will give us the following SQL-like expression:
     *
     * FilterA AND FilterB AND (FilterC OR FilterD) AND (FilterE OR FilterF)
     */
    //private var filters = mutableListOf<MutableList<Filter>>()

    func useOr() {
        //let filterRange = FilterRange(attribute: Attribute(""), isInverted: true)
        //let filterComp = FilterComparison(attribute: Attribute(""), isInverted: true)

    }
}
