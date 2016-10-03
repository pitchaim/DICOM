# DICOM
Matlab scripts for interacting with (DICOM)[https://en.wikipedia.org/wiki/DICOM] files.

##renameDicomSeries
Takes as parameter the name of a directory containing sub-directories of DICOM files (each sub-directory representing the output of one series).
Reads the 'SeriesDescription' field from the metadata of the first file in each sub-directory, copies contents of each sub-directory into new directory with the name of the series, and includes a log file ('DICOM_log.txt') of all files copied for each sub-directory.

(C) 2016 Austin Marcus

*Uploaded 10/3/2016 (Austin Marcus)*

###*LICENSE*

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
