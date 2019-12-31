#include "photolist.h"

void PhotoList::add(QVector<PhotoData> v) {
    beginInsertRows(QModelIndex(), rowCount(), rowCount());
    m_photodata << v;
    endInsertRows();
}

void PhotoList::clear() {
    beginResetModel();
    m_photodata.clear();
    endResetModel();
}

int PhotoList::rowCount() const {
    return m_photodata.count();
}

int PhotoList::rowCount(const QModelIndex &) const {
    return rowCount();
}

QVariant PhotoList::data(const QModelIndex &index, int role) const {
    if (index.row() < m_photodata.size())
        switch (role) {
        case Roles::URL_THUMBNAIL:
            return m_photodata[index.row()].url_thumbnail;
            break;
        case Roles::URL_PHOTO:
            return m_photodata[index.row()].url_photo;
            break;
        case Roles::URL_PHOTO_HQ:
            return m_photodata[index.row()].url_photo_hq;
            break;
        case Roles::HQ:
            return m_photodata[index.row()].hq;
            break;
        }
    return "";
}

QHash<int, QByteArray> PhotoList::roleNames() const {
    return QHash<int, QByteArray> ({
       { Roles::URL_THUMBNAIL, "url_thumbnail" },
       { Roles::URL_PHOTO, "url_photo" },
       { Roles::URL_PHOTO_HQ, "url_photo_hq" },
       { Roles::HQ, "hq" },
    });
}
