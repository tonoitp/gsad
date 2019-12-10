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

import styled from 'styled-components';

import _ from 'gmp/locale';

import Divider from 'web/components/layout/divider';

import InfoPanel from 'web/components/panel/infopanel';

import FilterIcon from 'web/components/icon/filtericon';

import PropTypes from 'web/utils/proptypes';

import ReportPanel from './reportpanel';
import EditIcon from 'web/components/icon/editicon';
import FootNote from 'web/components/footnote/footnote';
import Layout from 'web/components/layout/layout';

const UpdatingDivider = styled(({isUpdating, ...props}) => (
  <Divider {...props} />
))`
  opacity: ${props => (props.isUpdating ? '0.2' : '1.0')};
`;

const ThresholdPanel = ({
  entityType,
  filter,
  isUpdating = false,
  onFilterChanged,
  onFilterEditClick,
}) => {
  const levels = filter.get('levels', '');
  const severity = filter.get('severity', 0);

  const handleRemoveLogLevel = () => {
    if (levels.includes('g')) {
      const newLevels = levels.replace('g', '');
      const lfilter = filter.copy();
      lfilter.set('levels', newLevels);

      onFilterChanged(lfilter);
    }
  };

  const handleRemoveLowLevel = () => {
    if (levels.includes('l')) {
      const newLevels = levels.replace('l', '');
      const lfilter = filter.copy();
      lfilter.set('levels', newLevels);

      onFilterChanged(lfilter);
    }
  };

  const handleRemoveMediumLevel = () => {
    if (levels.includes('m')) {
      const newLevels = levels.replace('m', '');
      const lfilter = filter.copy();
      lfilter.set('levels', newLevels);

      onFilterChanged(lfilter);
    }
  };
  const handleSetMinimumSeverity = () => {
    const lfilter = filter.copy();
    lfilter.set('severity', 7.0, '>');

    onFilterChanged(lfilter);
  };
  return (
    <UpdatingDivider
      flex="column"
      align={['start', 'stretch']}
      grow
      isUpdating={isUpdating}
    >
      <InfoPanel
        heading={_(
          "The {{entityType}} can't be displayed, because the " +
            'report contains too many results. Please decrease the number ' +
            'of results by applying a different filter.',
          {entityType},
        )}
      />
      <Divider wrap>
        {levels.includes('g') && (
          <ReportPanel
            icon={props => <FilterIcon {...props} />}
            title={_('Log messages are currently included.')}
            onClick={handleRemoveLogLevel}
          >
            {_('Filter out log messages via your filter settings.')}
          </ReportPanel>
        )}
        {levels.includes('l') && (
          <ReportPanel
            icon={props => <FilterIcon {...props} />}
            title={_('Results with low severity are currently included.')}
            onClick={handleRemoveLowLevel}
          >
            {_(
              'Filter out results with low severity via your filter settings.',
            )}
          </ReportPanel>
        )}
        {levels.includes('m') && (
          <ReportPanel
            icon={props => <FilterIcon {...props} />}
            title={_('Results with medium severity are currently included.')}
            onClick={handleRemoveMediumLevel}
          >
            {_(
              'Filter out results with medium severity via your filter ' +
                'settings.',
            )}
          </ReportPanel>
        )}
        {!filter.has('levels') && severity < 7 && (
          <ReportPanel
            icon={props => <FilterIcon {...props} />}
            title={_("Results aren't filtered by severity.")}
            onClick={handleSetMinimumSeverity}
          >
            {_('Apply a minimum severity of 7.0.')}
          </ReportPanel>
        )}
        <ReportPanel
          icon={props => <EditIcon {...props} />}
          title={_('Your filter settings may be too unrefined.')}
          onClick={onFilterEditClick}
        >
          {_('Adjust and update your filter settings.')}
        </ReportPanel>
      </Divider>
      <Layout align="space-between">
        <FootNote>
          {_('(Applied filter: {{- filter}})', {
            filter: filter.simple().toFilterString(),
          })}
        </FootNote>
      </Layout>
    </UpdatingDivider>
  );
};

ThresholdPanel.propTypes = {
  entityType: PropTypes.string.isRequired,
  filter: PropTypes.filter.isRequired,
  isUpdating: PropTypes.bool,
  onFilterChanged: PropTypes.func.isRequired,
  onFilterEditClick: PropTypes.func.isRequired,
};

export default ThresholdPanel;
