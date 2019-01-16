/* Copyright (C) 2017-2019 Greenbone Networks GmbH
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 */
import React from 'react';

import {_l} from 'gmp/locale/lang';

import Layout from '../../components/layout/layout.js';

/* eslint-disable max-len */

import ApplyOverridesGroup from '../../components/powerfilter/applyoverridesgroup.js';
import FilterStringGroup from '../../components/powerfilter/filterstringgroup.js';
import FirstResultGroup from '../../components/powerfilter/firstresultgroup.js';
import MinQodGroup from '../../components/powerfilter/minqodgroup.js';
import ResultsPerPageGroup from '../../components/powerfilter/resultsperpagegroup.js';
import SortByGroup from '../../components/powerfilter/sortbygroup.js';
import withFilterDialog from '../../components/powerfilter/withFilterDialog.js';
import FilterDialogPropTypes from '../../components/powerfilter/dialogproptypes.js';

/* eslint-enable */


const SORT_FIELDS = [
  {
    name: 'date',
    displayName: _l('Date'),
  },
  {
    name: 'status',
    displayName: _l('Status'),
  },
  {
    name: 'task',
    displayName: _l('Task'),
  },
  {
    name: 'severity',
    displayName: _l('Severity'),
  },
  {
    name: 'high',
    displayName: _l('Scan Results: High'),
  },
  {
    name: 'medium',
    displayName: _l('Scan Results: Medium'),
  },
  {
    name: 'low',
    displayName: _l('Scan Results: Low'),
  },
  {
    name: 'log',
    displayName: _l('Scan Results: Log'),
  },
  {
    name: 'false_positive',
    displayName: _l('Scan Results: False Positive'),
  },
];

const ReportFilterDialogComponent = ({
    filter,
    filterstring,
    onFilterStringChange,
    onFilterValueChange,
    onSortByChange,
    onSortOrderChange,
  }) => {

  if (!filter) {
    return null;
  }

  return (
    <Layout flex="column">

      <FilterStringGroup
        name="filterstring"
        filter={filterstring}
        onChange={onFilterStringChange}
      />

      <ApplyOverridesGroup filter={filter} onChange={onFilterValueChange}/>

      <MinQodGroup
        name="min_qod"
        filter={filter}
        onChange={onFilterValueChange}
      />

      <FirstResultGroup
        filter={filter}
        onChange={onFilterValueChange}
      />

      <ResultsPerPageGroup
        filter={filter}
        onChange={onFilterValueChange}
      />

      <SortByGroup
        filter={filter}
        fields={SORT_FIELDS}
        onSortOrderChange={onSortOrderChange}
        onSortByChange={onSortByChange}
      />

    </Layout>
  );
};

ReportFilterDialogComponent.propTypes = FilterDialogPropTypes;

export default withFilterDialog()(ReportFilterDialogComponent);

// vim: set ts=2 sw=2 tw=80:
