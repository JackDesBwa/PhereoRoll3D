#ifndef PHOTOLIST_H
#define PHOTOLIST_H

#include <QString>
#include <QAbstractListModel>

struct PhotoData {
    QString url_thumbnail;
    QString url_photo;
    QString url_photo_hq;
    bool hq;

    PhotoData(QString p_url_thumbnail = "", QString p_url_photo = "", QString p_url_photo_hq = "", bool p_hq = false) {
        url_thumbnail = p_url_thumbnail;
        url_photo = p_url_photo;
        url_photo_hq = p_url_photo_hq;
        hq = p_hq;
    }
};

class PhotoList : public QAbstractListModel {
public:
    void add(QVector<PhotoData> v);
    void clear();

    int rowCount() const;
    int rowCount(const QModelIndex &) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    struct Roles {
        enum {
            URL_THUMBNAIL = Qt::UserRole,
            URL_PHOTO,
            URL_PHOTO_HQ,
            HQ,
        };
    };

private:
    QVector<PhotoData> m_photodata;
};

#endif // PHOTOLIST_H
