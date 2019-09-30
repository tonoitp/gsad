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

import _ from 'gmp/locale';

import {REPORT_FORMATS_FILTER_FILTER} from 'gmp/models/filter';

import PropTypes from 'web/utils/proptypes';
import withCapabilities from 'web/utils/withCapabilities';

import EntitiesPage from 'web/entities/page';
import withEntitiesContainer from 'web/entities/withEntitiesContainer';

import ManualIcon from 'web/components/icon/manualicon';
import ImportIcon from 'web/components/icon/importicon';
import ReportFormatIcon from 'web/components/icon/reportformaticon';

import IconDivider from 'web/components/layout/icondivider';

import {createFilterDialog} from 'web/components/powerfilter/dialog';

import {
  loadEntities,
  selector as entitiesSelector,
} from 'web/store/entities/reportformats';

import ReportFormatComponent from './component';
import ReportFormatsTable, {SORT_FIELDS} from './table';

const ToolBarIcons = withCapabilities(
  ({capabilities, onReportFormatImportClick}) => (
    <IconDivider>
      <ManualIcon
        page="reports"
        anchor="managing-report-formats"
        title={_('Help: Report Formats')}
      />
      {capabilities.mayCreate('report_format') && (
        <ImportIcon
          title={_('Import Report Format')}
          onClick={onReportFormatImportClick}
        />
      )}
    </IconDivider>
  ),
);

ToolBarIcons.propTypes = {
  onReportFormatImportClick: PropTypes.func.isRequired,
};

const ReportFormatsFilterDialog = createFilterDialog({
  sortFields: SORT_FIELDS,
});

const ReportFormatsPage = ({
  onChanged,
  onDownloaded,
  onError,
  onInteraction,
  showSuccess,
  ...props
}) => (
  <ReportFormatComponent
    onSaved={onChanged}
    onDeleted={onChanged}
    onDeleteError={onError}
    onDownloaded={onDownloaded}
    onDownloadError={onError}
    onImported={onChanged}
    onInteraction={onInteraction}
  >
    {({delete: delete_func, download, edit, import: import_func, save}) => (
      <EntitiesPage
        {...props}
        filterEditDialog={ReportFormatsFilterDialog}
        filtersFilter={REPORT_FORMATS_FILTER_FILTER}
        sectionIcon={<ReportFormatIcon size="large" />}
        table={ReportFormatsTable}
        title={_('Report Formats')}
        toolBarIcons={ToolBarIcons}
        onChanged={onChanged}
        onDownloaded={onDownloaded}
        onError={onError}
        onInteraction={onInteraction}
        onReportFormatImportClick={import_func}
        onReportFormatDeleteClick={delete_func}
        onReportFormatDownloadClick={download}
        onReportFormatEditClick={edit}
      />
    )}
  </ReportFormatComponent>
);

ReportFormatsPage.propTypes = {
  showSuccess: PropTypes.func.isRequired,
  onChanged: PropTypes.func.isRequired,
  onDownloaded: PropTypes.func.isRequired,
  onError: PropTypes.func.isRequired,
  onInteraction: PropTypes.func.isRequired,
};

export default withEntitiesContainer('reportformat', {
  entitiesSelector,
  loadEntities,
})(ReportFormatsPage);

// vim: set ts=2 sw=2 tw=80:
